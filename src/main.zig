const std = @import("std");
const info = @import("info.zig");
const runtime = @import("comet.zig").runtime;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 2) {
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
            try runtime(allocator, args[1]);
        },
    }
}
