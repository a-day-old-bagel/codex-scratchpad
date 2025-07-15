const std = @import("std");
const log = std.log.scoped(.zgpu);

const default_options = struct {
    const uniforms_buffer_size = 4 * 1024 * 1024;
    const dawn_skip_validation = false;
    const dawn_allow_unsafe_apis = false;
    const buffer_pool_size = 256;
    const texture_pool_size = 256;
    const texture_view_pool_size = 256;
    const sampler_pool_size = 16;
    const render_pipeline_pool_size = 128;
    const compute_pipeline_pool_size = 128;
    const bind_group_pool_size = 32;
    const bind_group_layout_pool_size = 32;
    const pipeline_layout_pool_size = 32;
    const max_num_bindings_per_group = 10;
    const max_num_bind_groups_per_pipeline = 4;
};

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const options = .{
        .uniforms_buffer_size = b.option(
            u64,
            "uniforms_buffer_size",
            "Set uniforms buffer size",
        ) orelse default_options.uniforms_buffer_size,
        .dawn_skip_validation = b.option(
            bool,
            "dawn_skip_validation",
            "Disable Dawn validation",
        ) orelse default_options.dawn_skip_validation,
        .dawn_allow_unsafe_apis = b.option(
            bool,
            "dawn_allow_unsafe_apis",
            "Allow unsafe WebGPU APIs (e.g. timestamp queries)",
        ) orelse default_options.dawn_allow_unsafe_apis,
        .buffer_pool_size = b.option(
            u32,
            "buffer_pool_size",
            "Set buffer pool size",
        ) orelse default_options.buffer_pool_size,
        .texture_pool_size = b.option(
            u32,
            "texture_pool_size",
            "Set texture pool size",
        ) orelse default_options.texture_pool_size,
        .texture_view_pool_size = b.option(
            u32,
            "texture_view_pool_size",
            "Set texture view pool size",
        ) orelse default_options.texture_view_pool_size,
        .sampler_pool_size = b.option(
            u32,
            "sampler_pool_size",
            "Set sample pool size",
        ) orelse default_options.sampler_pool_size,
        .render_pipeline_pool_size = b.option(
            u32,
            "render_pipeline_pool_size",
            "Set render pipeline pool size",
        ) orelse default_options.render_pipeline_pool_size,
        .compute_pipeline_pool_size = b.option(
            u32,
            "compute_pipeline_pool_size",
            "Set compute pipeline pool size",
        ) orelse default_options.compute_pipeline_pool_size,
        .bind_group_pool_size = b.option(
            u32,
            "bind_group_pool_size",
            "Set bind group pool size",
        ) orelse default_options.bind_group_pool_size,
        .bind_group_layout_pool_size = b.option(
            u32,
            "bind_group_layout_pool_size",
            "Set bind group layout pool size",
        ) orelse default_options.bind_group_layout_pool_size,
        .pipeline_layout_pool_size = b.option(
            u32,
            "pipeline_layout_pool_size",
            "Set pipeline layout pool size",
        ) orelse default_options.pipeline_layout_pool_size,
        .max_num_bindings_per_group = b.option(
            u32,
            "max_num_bindings_per_group",
            "Set maximum number of bindings per bind group",
        ) orelse default_options.max_num_bindings_per_group,
        .max_num_bind_groups_per_pipeline = b.option(
            u32,
            "max_num_bind_groups_per_pipeline",
            "Set maximum number of bindings groups per pipeline",
        ) orelse default_options.max_num_bind_groups_per_pipeline,
    };
    const options_step = b.addOptions();
    inline for (std.meta.fields(@TypeOf(options))) |field| {
        options_step.addOption(field.type, field.name, @field(options, field.name));
    }
    const options_module = options_step.createModule();

    const zgpu = b.addModule("zgpu", .{
        .root_source_file = b.path("src/zgpu.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "zgpu_options", .module = options_module },
            .{ .name = "zpool", .module = b.dependency("zpool", .{}).module("root") },
        },
    });

    const zgpu_tests = b.addTest(.{
        .name = "zgpu-tests",
        .root_module = zgpu,
        .target = target,
        .optimize = optimize,
    });
    zgpu_tests.addIncludePath(b.path("lib/include"));
    zgpu_tests.linkLibC();

    const test_step = b.step("test", "Run zgpu tests");
    test_step.dependOn(&b.addRunArtifact(zgpu_tests).step);
}
