# libversion-zig

This package is a thin wrapper around [libversion](https://github.com/repology/libversion)'s C API.
Its release version is in synchronization with [libversion release](https://github.com/repology/libversion/releases).

# Installation

```sh
zig fetch --save git+https://github.com/godsarmy/libversion-zig
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
    libversion.versionCompare2("1.0", "1.1");  // return -1
    libversion.versionCompare2("2.0", "1.9");  // return 1
    libversion.versionCompare2("2.0", "2.0");  // return 0

    // execute versionCompare4
    libversion.versionCompare4(
        "1.0p1",
        "1.0pre1",
        libversion.flags.VERSIONFLAG_P_IS_PATCH,
        libversion.flags.VERSIONFLAG_P_IS_PATCH,
    );  // return 1
    libverison.versionCompare4(
        "1.0p1",
        "1.0patch1",
        libversion.flags.VERSIONFLAG_P_IS_PATCH,
        libversion.flags.VERSIONFLAG_P_IS_PATCH,
    );  // return 0
    libversion.versionCompare4(
        "1.0p1",
        "1.0post1",
        libversion.flags.VERSIONFLAG_P_IS_PATCH,
        libversion.flags.VERSIONFLAG_P_IS_PATCH,
    );  // return 0
    ```

# Zig Release support

`libversion-zig` keeps track the specification of latest [stable version of Zig](https://ziglang.org/download/).
Currently, it can only be built by [Zig 0.14](https://ziglang.org/download/0.14.0/release-notes.html).
The plan is to support releases once Zig 1.0 is released but this can still change.

# Development & Build

 - Install [Zig 0.14]
 - In workspace, run build/test by `zig` command.
    ```sh
    zig build test
    ```
