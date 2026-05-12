const std = @import("std");
const http = std.http;
const main = @import("main.zig"); // To access PORT

pub fn sendStatic(req: *http.Server.Request, body: []const u8, content_type: []const u8) !void {
    try req.respond(body, .{
        .extra_headers = &.{
            .{ .name = "content-type", .value = content_type },
        },
    });
}

pub fn sendText(req: *http.Server.Request, body: []const u8) !void {
    try req.respond(body, .{
        .extra_headers = &.{
            .{ .name = "content-type", .value = "text/plain; charset=utf-8" },
        },
    });
}

pub fn sendJson(req: *http.Server.Request, gpa: std.mem.Allocator) !void {
    const body = try std.fmt.allocPrint(gpa,
        \\{{"server":"zig","version":"0.16","status":"ok","port":{d}}}
    , .{main.PORT});
    defer gpa.free(body);
    
    try req.respond(body, .{
        .extra_headers = &.{
            .{ .name = "content-type", .value = "application/json" },
        },
    });
}

pub fn sendWithLayout(
    req: *http.Server.Request,
    gpa: std.mem.Allocator,
    layout: []const u8,   // <-- caller passes it in
    body: []const u8,
) !void {
    var iter = std.mem.splitSequence(u8, layout, "<!-- CONTENT -->");
    const head = iter.next() orelse layout;
    const foot = iter.next() orelse "";

    const full_page = try std.mem.concat(gpa, u8, &[_][]const u8{ head, body, foot });
    defer gpa.free(full_page);

    try req.respond(full_page, .{
        .extra_headers = &.{
            .{ .name = "content-type", .value = "text/html; charset=utf-8" },
        },
    });
}

pub fn send404(req: *http.Server.Request) !void {
    try req.respond("404 Not Found\n", .{
        .status = .not_found,
        .extra_headers = &.{
            .{ .name = "content-type", .value = "text/plain" },
        },
    });
}