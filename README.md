# libversion-zig

This package is a thin wrapper around [libversion](https://github.com/repology/libversion)'s C API.
Its release version is in synchronization with [libversion release](https://github.com/repology/libversion/releases).

# Installation

```sh
zig fetch --save git+https://github.com/godsarmy/libversion-zig
```

# Zig Release support

`libversion-zig` keeps track the latest [stable version of Zig](https://ziglang.org/download/). Currently, it can
only be built by [Zig 0.14](https://ziglang.org/download/0.14.0/release-notes.html). The plan is to support releases once Zig 1.0 is released but this can still change.

# Development & Build

 - Install [Zig 0.14]
 - In workspace, run build/test by `zig` command.
    ```sh
    zig build test
    ```
