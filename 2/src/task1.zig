const std = @import("std");

const State = union(enum) { Start, Started: i32, Increasing: i32, Decreasing: i32, Invalid };

const StateMachine = struct {
    state: State,

    pub fn new() StateMachine {
        return StateMachine{ .state = State.Start };
    }

    pub fn fetchState(self: StateMachine) State {
        return self.state;
    }

    pub fn feed(self: *StateMachine, value: i32) void {
        const prev_state = self.state;

        self.state = switch (self.state) {
            State.Start => State{ .Started = value },
            State.Started => |current| transitionStarted(current, value),
            State.Increasing => |current| transitionIncreasing(current, value),
            State.Decreasing => |current| transitionDecreasing(current, value),
            else => State.Invalid,
        };

        std.debug.print("{} + {} => {}\n", .{ prev_state, value, self.state });
    }

    fn transitionStarted(current: i32, next: i32) State {
        if (current < next) {
            return transitionIncreasing(current, next);
        }
        if (current > next) {
            return transitionDecreasing(current, next);
        } else {
            return State.Invalid;
        }
    }

    fn transitionIncreasing(current: i32, next: i32) State {
        if (current < next and current + 4 > next) {
            return State{ .Increasing = next };
        } else {
            return State.Invalid;
        }
    }

    fn transitionDecreasing(current: i32, next: i32) State {
        if (current > next and current - 4 < next) {
            return State{ .Decreasing = next };
        } else {
            return State.Invalid;
        }
    }
};

pub fn run() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buf: [255]u8 = undefined;
    var counter: u32 = 0;

    while (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
        if (user_input.len == 0)
            break;

        var sm = StateMachine.new();
        var it = std.mem.split(u8, user_input, " ");
        while (it.next()) |x| {
            const value = try std.fmt.parseInt(i32, x, 10);
            sm.feed(value);
        }

        if (sm.fetchState() != State.Invalid) {
            try stdout.print("Valid\n", .{});
            counter += 1;
        } else {
            try stdout.print("Invalid\n", .{});
        }
    }

    try stdout.print("No. valid: {}\n", .{counter});
}
