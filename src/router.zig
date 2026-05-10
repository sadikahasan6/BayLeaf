const std = @import("std");
const http = std.http;
const handlers = @import("handlers.zig");

const assets = struct {
    const index = @embedFile("assets/index.html");
    const style = @embedFile("assets/style.css");
    const hero_bg = @embedFile("assets/hero-bg.jpg");
    const favicon = @embedFile("assets/favicon.svg");
};

pub fn route(req: *http.Server.Request, gpa: std.mem.Allocator) !void {
    const target = req.head.target;
    std.log.info("{s} {s}", .{ @tagName(req.head.method), target });

    if (std.mem.eql(u8, target, "/") or std.mem.eql(u8, target, "/index.html")) {
        try handlers.sendStatic(req, assets.index, "text/html; charset=utf-8");
    } else if (std.mem.eql(u8, target, "/favicon.svg")) {
        try handlers.sendStatic(req, assets.favicon, "image/svg+xml");
    } else if (std.mem.eql(u8, target, "/style.css")) {
        try handlers.sendStatic(req, assets.style, "text/css");
    } else if (std.mem.eql(u8, target, "/hero-bg.jpg")) {
        try handlers.sendStatic(req, assets.hero_bg, "image/jpeg");
    } else if (std.mem.eql(u8, target, "/hello")) {
        try handlers.sendText(req, "Hello from Zig 0.16! 🦎\n");
    } else if (std.mem.eql(u8, target, "/json")) {
        try handlers.sendJson(req, gpa);
    } else {
        try handlers.send404(req);
    }
}
