const std = @import("std");
const http = std.http;
const handlers = @import("handlers.zig");

pub const assets = struct {
    pub const favicon = @embedFile("assets/favicon.svg");
    pub const style = @embedFile("assets/style.css");
    pub const script = @embedFile("assets/script.js");
    pub const layout = @embedFile("assets/layouts/layout.html");

    pub const index = @embedFile("assets/index.html");
    pub const about = @embedFile("assets/about.html");
    pub const docs = @embedFile("assets/docs.html");

    const hero_bg = @embedFile("assets/hero-bg.jpg");
};

pub fn route(req: *http.Server.Request, gpa: std.mem.Allocator) !void {
    const target = req.head.target;
    std.log.info("{s} {s}", .{ @tagName(req.head.method), target });

    if (std.mem.eql(u8, target, "/") or std.mem.eql(u8, target, "/index.html")) {
        try handlers.sendWithLayout(req,gpa,assets.layout, assets.index);
    } else if (std.mem.eql(u8, target, "/favicon.svg")) {
        try handlers.sendStatic(req, assets.favicon, "image/svg+xml");
    } else if (std.mem.eql(u8, target, "/style.css")) {
        try handlers.sendStatic(req, assets.style, "text/css");
    } else if (std.mem.eql(u8, target, "/script.js")) {
        try handlers.sendStatic(req, assets.style, "text/javascript");
    } else if (std.mem.eql(u8, target, "/hero-bg.jpg")) {
        try handlers.sendStatic(req, assets.hero_bg, "image/jpeg");
    } else if (std.mem.eql(u8, target, "/about")) {
        try handlers.sendWithLayout(req, gpa, assets.layout, assets.about);
    } else if (std.mem.eql(u8, target, "/docs")) {
        try handlers.sendWithLayout(req, gpa, assets.layout, assets.docs);
    } else if (std.mem.eql(u8, target, "/hello")) {
        try handlers.sendText(req, "Hello from Zig 0.16! 🦎\n");
    } else if (std.mem.eql(u8, target, "/json")) {
        try handlers.sendJson(req, gpa);
    } else {
        try handlers.send404(req);
    }
}
