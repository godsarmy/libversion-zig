const std = @import("std");



pub fn build(b: *std.Build) !void {
    var flags = std.array_list.Managed([]const u8).init(b.allocator);
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

    const mod = b.createModule(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .link_libc = true,
        .optimize = optimize,
    });
    mod.addIncludePath(libversion_dep.path("."));
    mod.addIncludePath(build_dir);

    b.getInstallStep().dependOn(&cmake_step.step);
    const lib = b.addLibrary(.{
        .name = "libversion-zig",
        .linkage = .static,
        .root_module = mod,
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
    b.installArtifact(lib);

    const test_exe = b.addTest(.{
        .name = "libversion-zig-test",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/lib.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    test_exe.addIncludePath(libversion_dep.path("."));
    test_exe.addIncludePath(build_dir);
    test_exe.linkLibrary(lib);
    const run_tests = b.addRunArtifact(test_exe);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_tests.step);
}
