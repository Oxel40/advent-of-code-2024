const std = @import("std");
const task1 = @import("task1.zig");
const task2 = @import("task2.zig");

pub fn main() !void {
    var args = std.process.args();
    _ = args.skip(); //to skip the zig call

    const task = args.next();

    if (task) |task_num| {
        switch (try std.fmt.parseInt(u32, task_num, 10)) {
            1 => try task1.run(),
            2 => try task2.run(),
            else => std.debug.print("Invalid task number {s}\n", .{task_num}),
        }
    } else {
        std.debug.print("Expected one arg\n", .{});
    }
}
