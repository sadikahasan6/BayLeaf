const std = @import("std");

pub fn build(b: *std.Build) void {

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "BayLeaf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{ },
        }),
    });

    b.installArtifact(exe);

    // Add this block here:
    if (target.result.os.tag == .windows) {
        // Note the .root_module here
        exe.root_module.addWin32ResourceFile(.{
            .file = b.path("resources.rc"),
            .include_paths = &.{},
        });
    }

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }


}
