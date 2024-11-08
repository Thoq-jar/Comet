const std = @import("std");
const c = @cImport({
    @cInclude("JavaScriptCore/JavaScript.h");
});

pub const Module = struct {
    allocator: std.mem.Allocator,
    path: []const u8,
    content: []const u8,
    context: c.JSGlobalContextRef,
    exports: c.JSObjectRef,

    pub fn init(allocator: std.mem.Allocator, path: []const u8) !*Module {
        const content = try std.fs.cwd().readFileAlloc(allocator, path, 1024 * 1024);
        
        const module = try allocator.create(Module);
        module.* = .{
            .allocator = allocator,
            .path = try allocator.dupe(u8, path),
            .content = content,
            .context = c.JSGlobalContextCreate(null),
            .exports = undefined,
        };
        
        return module;
    }

    pub fn deinit(self: *Module) void {
        self.allocator.free(self.content);
        self.allocator.free(self.path);
        c.JSGlobalContextRelease(self.context);
        self.allocator.destroy(self);
    }
};

pub const ModuleRegistry = struct {
    allocator: std.mem.Allocator,
    modules: std.StringHashMap(*Module),

    pub fn init(allocator: std.mem.Allocator) ModuleRegistry {
        return .{
            .allocator = allocator,
            .modules = std.StringHashMap(*Module).init(allocator),
        };
    }

    pub fn deinit(self: *ModuleRegistry) void {
        var it = self.modules.iterator();
        while (it.next()) |entry| {
            entry.value_ptr.*.deinit();
        }
        self.modules.deinit();
    }

    pub fn loadModule(self: *ModuleRegistry, path: []const u8) !*Module {
        if (self.modules.get(path)) |module| {
            return module;
        }

        const module = try Module.init(self.allocator, path);
        try self.modules.put(path, module);
        return module;
    }
}; 