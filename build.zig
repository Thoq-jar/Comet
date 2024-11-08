const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "Comet",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    switch (target.getOsTag()) {
        .macos => {
            exe.linkFramework("JavaScriptCore");
        },
        .linux => {
            exe.linkSystemLibrary("javascriptcoregtk-4.0");
            exe.linkLibC();
        },
        else => @panic("Unsupported OS! ({s})", .{@tagName(target.getOsTag())}),
    }

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}