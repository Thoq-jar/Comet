const std = @import("std");
const io = @import("io.zig");
const c = @cImport({
    @cInclude("JavaScriptCore/JavaScript.h");
});

pub fn runtime(allocator: std.mem.Allocator, file_path: []const u8) !void {
    const js_content = try std.fs.cwd().readFileAlloc(allocator, file_path, 1024 * 1024);
    defer allocator.free(js_content);

    var script_content = try allocator.alloc(u8, js_content.len + 1);
    defer allocator.free(script_content);
    
    @memcpy(script_content[0..js_content.len], js_content);
    script_content[js_content.len] = 0;

    const context = c.JSGlobalContextCreate(null);
    defer c.JSGlobalContextRelease(context);

    io.setupConsole(context);

    const script = c.JSStringCreateWithUTF8CString(script_content.ptr);
    defer c.JSStringRelease(script);

    const result = c.JSEvaluateScript(
        context,
        script,
        null,
        null,
        0,
        null,
    );

    if (result == null) {
        std.debug.print("Error: Script evaluation failed\n", .{});
        return error.ScriptEvaluationFailed;
    }
}
