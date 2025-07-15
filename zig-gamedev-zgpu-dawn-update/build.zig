const std = @import("std");
const log = std.log.scoped(.zgpu);

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const zgpu_tests = b.addTest(.{
        .name = "zgpu-tests",
        .root_source_file = b.path("src/zgpu.zig"),
        .target = target,
        .optimize = optimize,
    });
    zgpu_tests.addIncludePath(b.path("lib/include"));
    zgpu_tests.linkLibC();

    const test_step = b.step("test", "Run zgpu tests");
    test_step.dependOn(&b.addRunArtifact(zgpu_tests).step);
}
