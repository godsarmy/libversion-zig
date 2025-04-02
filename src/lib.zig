const std = @import("std");

const c = @cImport({
    @cInclude("libversion/version.h");
});

const flags = enum {
    const VERSIONFLAG_P_IS_PATCH = 0x1;
    const VERSIONFLAG_ANY_IS_PATCH = 0x2;
    const VERSIONFLAG_LOWER_BOUND = 0x4;
    const VERSIONFLAG_UPPER_BOUND = 0x8;
};

pub fn versionCompare2(version1: [:0]const u8, version2: [:0]const u8) i32 {
    return c.version_compare2(version1.ptr, version2.ptr);
}

pub fn versionCompare4(version1: [:0]const u8, version2: [:0]const u8, version1_flags: i32, version2_flags: i32) i32 {
    return c.version_compare4(version1.ptr, version2.ptr, version1_flags, version2_flags);
}

test "versionCompare" {
    try std.testing.expectEqual(versionCompare2("1.0", "1.1"), -1);
    try std.testing.expectEqual(versionCompare2("2.0", "1.9"), 1);
    try std.testing.expectEqual(versionCompare2("1.5", "1.5"), 0);
    try std.testing.expectEqual(versionCompare4("1.5", "1.5", 0, 0), 0);
    try std.testing.expectEqual(versionCompare4("1.5", "1.5", 0, 0), 0);
    try std.testing.expectEqual(versionCompare4("1.0p1", "1.0pre1", flags.VERSIONFLAG_P_IS_PATCH, flags.VERSIONFLAG_P_IS_PATCH), 1);
    try std.testing.expectEqual(versionCompare4("1.0p1", "1.0patch1", flags.VERSIONFLAG_P_IS_PATCH, flags.VERSIONFLAG_P_IS_PATCH), 0);
    try std.testing.expectEqual(versionCompare4("1.0p1", "1.0post1", flags.VERSIONFLAG_P_IS_PATCH, flags.VERSIONFLAG_P_IS_PATCH), 0);
}
