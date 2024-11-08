const std = @import("std");
const info = @import("info.zig");
const runtime = @import("comet.zig").runtime;

fn runNpmCommand(allocator: std.mem.Allocator, args: []const []const u8) !void {
    var npm_args = std.ArrayList([]const u8).init(allocator);
    defer npm_args.deinit();

    try npm_args.append("npm");

    for (args) |arg| {
        try npm_args.append(arg);
    }

    var child = std.process.Child{
        .allocator = allocator,
        .argv = npm_args.items,
        .cwd = null,
        .env_map = null,
        .stdin_behavior = .Inherit,
        .stdout_behavior = .Inherit,
        .stderr_behavior = .Inherit,
        .expand_arg0 = .no_expand,
        .uid = null,
        .gid = null,
        .err_pipe = null,
        .term = null,
        .id = undefined,
        .thread_handle = undefined,
        .stdin = undefined,
        .stdout = undefined,
        .stderr = undefined,
    };

    try child.spawn();
    _ = try child.wait();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        try info.help();
        return;
    }

    switch (args[1][0]) {
        '-' => {
            if (std.mem.eql(u8, args[1], "-v") or std.mem.eql(u8, args[1], "--version")) {
                try info.version();
                return;
            } else if (std.mem.eql(u8, args[1], "-h") or std.mem.eql(u8, args[1], "--help")) {
                try info.help();
                return;
            }
        },
        else => {
            if (std.mem.eql(u8, args[1], "install") or 
                std.mem.eql(u8, args[1], "i") or 
                std.mem.eql(u8, args[1], "legacy")) {
                try runNpmCommand(allocator, args[1..]);
            } else {
                try runtime(allocator, args[1]);
            }
        },
    }
}
