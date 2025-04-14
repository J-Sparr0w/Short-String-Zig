# Short-String
a german string implementation in zig
### Note:
the same allocator used to initialize the string must be used in its deinit call.  
### Example:
```zig
test "basic functionality" {
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
```
#### Output:
![output:Size of String: 16Alignment of String: 8String: String {Len: 5Prefix: `shor`Rest (on the stack): `t`}String: String {Len: 13Prefix: `a lo`Rest (on the heap): a long string}Test Passed Successfully](image.png)