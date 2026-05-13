const std = @import("std");
const net = std.Io.net;
const conn = @import("connection.zig");
const builtin = @import("builtin");

extern "kernel32" fn SetConsoleOutputCP(wCodePageID: u32) callconv(.winapi) u32;

pub const HOST = "127.0.0.1";
pub const PORT = 10000;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;

    if (builtin.os.tag == .windows) {
        _ = SetConsoleOutputCP(65001);
    }

    const addr = try net.IpAddress.parse(HOST, PORT);
    var listener = try addr.listen(io, .{ .reuse_address = true });
    defer listener.deinit(io);

    std.debug.print("Welcome to the BayLeaf server 🍂\nVersion:0.0\n\n", .{});
    std.log.info("Listening on http://{s}:{d}", .{ HOST, PORT });

    while (true) {
        const stream = listener.accept(io) catch |err| {
            std.log.err("accept: {s}", .{@errorName(err)});
            continue;
        };

        const ctx = conn.ConnCtx{ .stream = stream, .io = io, .gpa = gpa };
        const t = std.Thread.spawn(.{}, conn.serveConn, .{ctx}) catch |err| {
            std.log.err("spawn: {s}", .{@errorName(err)});
            stream.close(io);
            continue;
        };
        t.detach();
    }
}