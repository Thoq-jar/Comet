const std = @import("std");
const c = @cImport({
    @cInclude("JavaScriptCore/JavaScript.h");
});

fn consoleLog(
    ctx: c.JSContextRef,
    _: c.JSObjectRef,
    _: c.JSObjectRef,
    argument_count: usize,
    arguments: [*c]const c.JSValueRef,
    _: [*c]c.JSValueRef,
) callconv(.C) c.JSValueRef {
    const stdout = std.io.getStdOut().writer();

    var i: usize = 0;
    while (i < argument_count) : (i += 1) {
        const js_string = c.JSValueToStringCopy(ctx, arguments[i], null);
        defer c.JSStringRelease(js_string);

        var buffer: [1024]u8 = undefined;
        _ = c.JSStringGetUTF8CString(js_string, &buffer, buffer.len);
        stdout.print("{s}", .{std.mem.sliceTo(&buffer, 0)}) catch {};

        if (i < argument_count - 1) {
            stdout.print(" ", .{}) catch {};
        }
    }
    stdout.print("\n", .{}) catch {};

    return c.JSValueMakeUndefined(ctx);
}

pub fn setupConsole(ctx: c.JSGlobalContextRef) void {
    const global = c.JSContextGetGlobalObject(ctx);

    const console_name = c.JSStringCreateWithUTF8CString("console");
    defer c.JSStringRelease(console_name);

    const console_obj = c.JSObjectMake(ctx, null, null);
    c.JSObjectSetProperty(ctx, global, console_name, console_obj, 0, null);

    const log_name = c.JSStringCreateWithUTF8CString("log");
    defer c.JSStringRelease(log_name);

    const log_func = c.JSObjectMakeFunctionWithCallback(ctx, log_name, consoleLog);
    c.JSObjectSetProperty(ctx, console_obj, log_name, log_func, 0, null);
}
