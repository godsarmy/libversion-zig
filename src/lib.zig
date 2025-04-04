const std = @import("std");

const c = @cImport({
    @cInclude("libversion/version.h");
});

pub const flag = enum {
    pub const VERSIONFLAG_P_IS_PATCH = 0x1;
    pub const VERSIONFLAG_ANY_IS_PATCH = 0x2;
    pub const VERSIONFLAG_LOWER_BOUND = 0x4;
    pub const VERSIONFLAG_UPPER_BOUND = 0x8;
};

pub fn versionCompare2(version1: [:0]const u8, version2: [:0]const u8) i32 {
    return c.version_compare2(version1.ptr, version2.ptr);
}

pub fn versionCompare4(version1: [:0]const u8, version2: [:0]const u8, version1_flags: i32, version2_flags: i32) i32 {
    return c.version_compare4(version1.ptr, version2.ptr, version1_flags, version2_flags);
}

test "versionCompare" {
    try std.testing.expectEqual(versionCompare2("1.0", "1.1"), -1);
    try std.testing.expectEqual(versionCompare2("1.2", "1.10"), -1);
    try std.testing.expectEqual(versionCompare2("0.0.10", "0.1.0"), -1);
    try std.testing.expectEqual(versionCompare2("1.0", "1.0a"), -1);
    try std.testing.expectEqual(versionCompare2("1.0a", "1.0b"), -1);
    try std.testing.expectEqual(versionCompare2("1.0a", "1.1"), -1);
    try std.testing.expectEqual(versionCompare2("1.0.a", "1.0.b"), -1);
    try std.testing.expectEqual(versionCompare2("1.0alpha2", "1.0beta1"), -1);

    try std.testing.expectEqual(versionCompare2("1.5", "1.5"), 0);
    try std.testing.expectEqual(versionCompare2("1.5a0", "1.5.a0"), 0);
    try std.testing.expectEqual(versionCompare2("1.5beta3", "1.5.b3"), 0);
    try std.testing.expectEqual(versionCompare2("alpha1", "ALPHA1"), 0);
    try std.testing.expectEqual(versionCompare2("1.0.alpha.2", "1-0-alpha-2"), 0);

    try std.testing.expectEqual(versionCompare2("2.0", "1.9"), 1);
    try std.testing.expectEqual(versionCompare2("1.0patch", "1.0"), 1);

    try std.testing.expectEqual(versionCompare4("1.5", "1.5", 0, 0), 0);
    try std.testing.expectEqual(versionCompare4("1.5", "1.5", 0, 0), 0);
    try std.testing.expectEqual(versionCompare4("1.0p1", "1.0pre1", flag.VERSIONFLAG_P_IS_PATCH, flag.VERSIONFLAG_P_IS_PATCH), 1);
    try std.testing.expectEqual(versionCompare4("1.0p1", "1.0patch1", flag.VERSIONFLAG_P_IS_PATCH, flag.VERSIONFLAG_P_IS_PATCH), 0);
    try std.testing.expectEqual(versionCompare4("1.0p1", "1.0post1", flag.VERSIONFLAG_P_IS_PATCH, flag.VERSIONFLAG_P_IS_PATCH), 0);

    try std.testing.expectEqual(versionCompare4("1.0a1", "1.0a1", 0, 0), 0);
    try std.testing.expectEqual(versionCompare4("1.0a1", "1.0a1", flag.VERSIONFLAG_ANY_IS_PATCH, flag.VERSIONFLAG_ANY_IS_PATCH), 0);
    try std.testing.expectEqual(versionCompare4("1.0a1", "1.0a1", flag.VERSIONFLAG_ANY_IS_PATCH, 0), 1);
    try std.testing.expectEqual(versionCompare4("1.0a1", "1.0a1", 0, flag.VERSIONFLAG_ANY_IS_PATCH), -1);
}
