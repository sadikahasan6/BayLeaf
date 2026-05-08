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

pub fn send404(req: *http.Server.Request) !void {
    try req.respond("404 Not Found\n", .{
        .status = .not_found,
        .extra_headers = &.{
            .{ .name = "content-type", .value = "text/plain" },
        },
    });
}