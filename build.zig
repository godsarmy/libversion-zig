const std = @import("std");
const Translator = @import("translate_c").Translator;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libversion_dep = b.dependency("libversion", .{
        .target = target,
        .optimize = optimize,
    });
    const upstream = libversion_dep.path(".");

    const cmake_step = b.addSystemCommand(&.{ "cmake", "-S" });
    cmake_step.addDirectoryArg(upstream);
    cmake_step.addArg("-B");
    const build_dir = cmake_step.addOutputDirectoryArg("out");

    const translator: Translator = .init(b.dependency("translate_c", .{}), .{
        .c_source_file = libversion_dep.path("libversion/version.h"),
        .target = target,
        .optimize = optimize,
    });
    translator.addIncludePath(upstream);
    translator.addIncludePath(build_dir);
    translator.defineCMacro("LIBVERSION_STATIC_DEFINE", null);

    const mod = b.addModule("libversion", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .link_libc = true,
        .optimize = optimize,
    });
    mod.addImport("c", translator.mod);
    mod.addIncludePath(upstream);
    mod.addIncludePath(build_dir);
    mod.addCSourceFiles(.{
        .root = upstream,
        .files = &.{
            "libversion/compare.c",
            "libversion/private/compare.c",
            "libversion/private/parse.c",
        },
        .flags = &.{ "-std=c99", "-DLIBVERSION_STATIC_DEFINE" },
    });

    const lib = b.addLibrary(.{
        .name = "libversion-zig",
        .linkage = .static,
        .root_module = mod,
    });
    b.installArtifact(lib);

    const test_exe = b.addTest(.{
        .name = "libversion-zig-test",
        .root_module = mod,
    });
    const run_tests = b.addRunArtifact(test_exe);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_tests.step);
}
