const std = @import("std");
const builtin = @import("builtin");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const lib = b.addStaticLibrary("ed25519js", "src/main.zig");

    lib.addIncludeDir("vendor/monocypher/src");
    lib.addIncludeDir("vendor/monocypher/src/optional");
    
    const monocypherFlags = &[_][]const u8{ "-std=c99" };
    lib.addCSourceFile("vendor/monocypher/src/optional/monocypher-ed25519.c", monocypherFlags);
    lib.addCSourceFile("vendor/monocypher/src/monocypher.c", monocypherFlags);
    
    lib.setBuildMode(mode);
    lib.setTarget(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
    });

    lib.install();

    var main_tests = b.addTest("src/main.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
