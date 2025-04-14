const std = @import("std");
const testing = std.testing;

const String = struct {
    len: u32,
    prefix: @Vector(4, u8),
    rest: packed union {
        trailing: @Vector(8, u8),
        ptr: [*]u8,
    },

    pub fn from_str(allocator: std.mem.Allocator, str: []const u8) !String {
        const len = str.len;
        if (len > std.math.maxInt(u32)) {
            return error.stringTooLong;
        }

        if (len <= 12) {
            var trailing: [8]u8 = .{0} ** 8;
            for (str[4..], 0..) |ch, i| {
                trailing[i] = ch;
            }
            // add to trailing
            return String{
                .len = @intCast(len),
                .prefix = str[0..4].*,
                .rest = .{
                    .trailing = trailing,
                },
            };
        } else {
            // add to heap
            const heap_str = try allocator.alloc(u8, len);
            std.mem.copyForwards(u8, heap_str, str[0..]);
            return String{
                .len = @intCast(len),
                .prefix = str[0..4].*,
                .rest = .{
                    .ptr = heap_str.ptr,
                },
            };
        }
    }
    pub fn is_heap_allocated(self: String) bool {
        return self.len > 12;
    }
    pub fn get_heap_ptr(self: String) ?[]u8 {
        if (is_heap_allocated(self)) {
            return self.rest.ptr[0..self.len];
        } else {
            return null;
        }
    }
    pub fn deinit(self: String, allocator: std.mem.Allocator) void {
        // self.len = 0;
        // self.prefix = [_]u8{0} ** 8;
        if (self.get_heap_ptr()) |ptr| {
            allocator.free(ptr);
        }
    }
    pub fn format(
        self: String,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        const prefix: [4]u8 = self.prefix;

        try writer.print("String {{\nLen: {}\nPrefix: `{s}`", .{
            self.len, prefix,
        });

        if (self.len <= 12) {
            const trailing: [8]u8 = self.rest.trailing;
            try writer.print("\nRest (on the stack): `{s}`", .{trailing});
        } else {
            try writer.print("\nRest (on the heap): {s}", .{self.rest.ptr[0..self.len]});
        }

        try writer.writeAll("\n}");
    }
};

pub fn main() void {
    std.log("Size of String: {}", .{@sizeOf(String)});
}

test "basic test functionality" {
    const allocator = std.testing.allocator;
    const short_str = try String.from_str(allocator, "short");
    defer short_str.deinit(allocator);
    const long_str = try String.from_str(allocator, "a long string");
    defer long_str.deinit(allocator);
    std.debug.print("\nSize of String: {}", .{@sizeOf(String)});
    std.debug.print("\nAlignment of String: {}", .{@alignOf(String)});
    std.debug.print("\nString: {s}", .{short_str});
    std.debug.print("\nString: {s}", .{long_str});
    try testing.expect(10 == 10);
    std.debug.print("\nTest Passed Successfully", .{});
}
