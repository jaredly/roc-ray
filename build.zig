const std = @import("std");
const raylib = @import("raylib/build.zig");
const raylib_build = @import("raylib/raylib/src/build.zig");
const raygui = @import("raygui/build.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    // Create a static library
    const lib = b.addStaticLibrary(.{
        .name = "roc-ray",
        .root_source_file = .{ .path = "platform/host.zig" },
        .target = target,
        .optimize = mode,
        .link_libc = true,
    });

    lib.force_pic = true;
    lib.disable_stack_probing = true;

    raylib.addTo(b, lib, target, mode, .{
        .raudio = true,
        .rmodels = true,
        .rshapes = true,
        .rtext = true,
        .rtextures = true,
        .raygui = false,
        .platform_drm = false,
    });
    // raygui.addTo(b, lib, target, mode);

    const lib_raylib = raylib_build.addRaylib(b, target, mode, .{});

    b.installArtifact(lib);
    b.installArtifact(lib_raylib);

    // Create a binary
    // const bin = b.addExecutable(.{
    //     .name = "roc-ray-bin",
    //     .root_source_file = .{ .path = "src.zig" },
    //     .target = target,
    //     .optimize = mode,
    //     .link_libc = true,
    // });

    // raylib.addTo(b, bin, target, mode, .{});
    // raygui.addTo(b, bin, target, mode);

    // b.installArtifact(bin);
}