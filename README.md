# libversion-zig

This package is a thin wrapper around [libversion](https://github.com/repology/libversion)'s C API.
Bindings are generated from the upstream C header at build time using the official [translate-c package](https://codeberg.org/ziglang/translate-c).
Release versions use `<libversion version>+zig.<Zig version>`, identifying both the [upstream libversion release](https://github.com/repology/libversion/releases) and the supported Zig compiler. The current release is `3.0.4+zig.0.17.0`.

# Installation

```sh
zig fetch --save 'git+https://github.com/godsarmy/libversion-zig#3.0.4+zig.0.17.0'
```
Now in your build.zig you can access the module like this:

```zig
const libversion = b.dependency("libversion", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("libversion", libversion.module("libversion"));
```

# Usage

 - Import `libversion-zig` like this:
    ```zig
    const libversion = @import("libversion");
    ```
 - Call Functions in `libversion-zig`
    ```zig
    // execute versionCompare2
    _ = libversion.versionCompare2("1.0", "1.1");  // return -1
    _ = libversion.versionCompare2("2.0", "1.9");  // return 1
    _ = libversion.versionCompare2("2.0", "2.0");  // return 0

    // execute versionCompare4
    _ = libversion.versionCompare4(
        "1.0p1",
        "1.0pre1",
        libversion.flag.VERSIONFLAG_P_IS_PATCH,
        libversion.flag.VERSIONFLAG_P_IS_PATCH,
    );  // return 1
    _ = libversion.versionCompare4(
        "1.0p1",
        "1.0patch1",
        libversion.flag.VERSIONFLAG_P_IS_PATCH,
        libversion.flag.VERSIONFLAG_P_IS_PATCH,
    );  // return 0
    _ = libversion.versionCompare4(
        "1.0p1",
        "1.0post1",
        libversion.flag.VERSIONFLAG_P_IS_PATCH,
        libversion.flag.VERSIONFLAG_P_IS_PATCH,
    );  // return 0
    ```

# Zig Release support

`libversion-zig` keeps track of the latest stable [Zig release](https://ziglang.org/download/).
Currently, it can be built by [Zig 0.17.0](https://ziglang.org/download/0.17.0/release-notes.html).
The plan is to support releases once Zig 1.0 is released, but this can still change.

# Development & Build

 - Install [Zig 0.17.0](https://ziglang.org/download/0.17.0/) and CMake 3.22.1 or newer. CMake generates the upstream C headers; Zig compiles the C sources.
 - Clone project by git.
 - In project workspace, run build/test by `zig` command.
    ```sh
    zig build
    zig build test
    zig fmt --check build.zig src/lib.zig
    ```
