const std = @import("std");



pub fn build(b: *std.Build) !void {
    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();
    try flags.append("-std=c99");

    const c_flags = flags.items;

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libversion_dep = b.dependency("libversion", .{
        .target = target,
        .optimize = optimize,
    });

    const cmake_step = b.addSystemCommand(&[_][]const u8{
        "cmake",
        "-S",
        libversion_dep.path(".").getPath(b),
        "-B",
    });
    const build_dir = cmake_step.addOutputDirectoryArg("out");

    b.getInstallStep().dependOn(&cmake_step.step);
    const lib = b.addStaticLibrary(.{
        .name = "libversion-zig",
        .target = target,
        .optimize = optimize,
    });
    lib.addIncludePath(libversion_dep.path("."));
    // build_dir Outputed by cmake_step. This make sure cmake_step runs first
    lib.addIncludePath(build_dir);
    lib.addCSourceFile(.{
        .file = libversion_dep.path("libversion/compare.c"),
        .flags = c_flags,
    });
    lib.addCSourceFile(.{
        .file = libversion_dep.path("libversion/private/compare.c"),
        .flags = c_flags,
    });
    lib.addCSourceFile(.{
        .file = libversion_dep.path("libversion/private/parse.c"),
        .flags = c_flags,
    });
    lib.linkLibC();

    const mod = b.addModule("libversion", .{
        .root_source_file = b.path("src/lib.zig"),
        .link_libc = true,
    });
    mod.addIncludePath(libversion_dep.path("."));
    mod.addIncludePath(build_dir);
    mod.linkLibrary(lib);

    b.installArtifact(lib);

    const test_step = b.step("test", "Run library tests");
    const test_exe = b.addTest(.{
         .root_source_file = b.path("src/lib.zig"), // Tests are often in the same lib.zig for small libs
         .target = target,
         .optimize = optimize,
    });
    test_exe.addIncludePath(libversion_dep.path("."));
    test_exe.addIncludePath(build_dir);
    test_exe.linkLibrary(lib);
    const run_tests = b.addRunArtifact(test_exe);
    test_step.dependOn(&run_tests.step);
}
