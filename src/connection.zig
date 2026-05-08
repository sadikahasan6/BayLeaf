const std = @import("std");
const net = std.Io.net;
const http = std.http;
const router = @import("router.zig");

pub const READ_BUF = 4096;
pub const WRITE_BUF = 4096;

pub const ConnCtx = struct {
    stream: net.Stream,
    io: std.Io,
    gpa: std.mem.Allocator,
};

pub fn serveConn(ctx: ConnCtx) void {
    defer ctx.stream.close(ctx.io);

    var rbuf: [READ_BUF]u8 = undefined;
    var wbuf: [WRITE_BUF]u8 = undefined;

    var net_reader = net.Stream.Reader.init(ctx.stream, ctx.io, &rbuf);
    var net_writer = net.Stream.Writer.init(ctx.stream, ctx.io, &wbuf);

    var server = http.Server.init(&net_reader.interface, &net_writer.interface);

    while (true) {
        var req = server.receiveHead() catch |err| switch (err) {
            error.HttpConnectionClosing => return,
            else => {
                std.log.err("receiveHead: {s}", .{@errorName(err)});
                return;
            },
        };
        router.route(&req, ctx.gpa) catch |err| {
            std.log.err("route: {s}", .{@errorName(err)});
            return;
        };
    }
}