const std = @import("std");

const versionText = "Comet v0.1.0\n";
const helpText =
    \\Comet: A high preformance JS/TS runtime.
    \\
    \\Usage: comet [options] [command]
    \\
    \\Commands:
    \\  ⬤ Runtime:
    \\      - Help: comet (Show this screen)
    \\      - Version: comet -v/--version (Show version info)
    \\      - Run: comet <yourfile.js/ts> (Run a JavaScript or TypeScript file)
    \\
    \\  ⬤ Package manager:
    \\      - Install: comet install/i (Install dependencies)
    \\
;

pub fn help() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{s}", .{helpText});
}

pub fn version() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{s}", .{versionText});
}
