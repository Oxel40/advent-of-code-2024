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

pub fn subroutine(array: []i32) bool {
    std.debug.print("\nStart: {any}\n", .{array});

    var sm = StateMachine.new();

    for (array) |v| {
        sm.feed(v);
    }

    if (sm.fetchState() != State.Invalid) {
        return true;
    } else {
        return false;
    }
}

pub fn run() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buf: [255]u8 = undefined;
    var numbers: [128]i32 = undefined;
    var input: [128]i32 = undefined;
    var counter: u32 = 0;

    reportLoop: while (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
        if (user_input.len == 0)
            break;

        std.debug.print("\n=====\nCase: {s}\n=====\n", .{user_input});

        var len: usize = 0;
        var it = std.mem.split(u8, user_input, " ");
        while (it.next()) |x| {
            const value = try std.fmt.parseInt(i32, x, 10);
            numbers[len] = value;
            len += 1;
        }
        const user_input_u32 = numbers[0..len];

        std.debug.print("{any}\n", .{user_input_u32});

        if (subroutine(numbers[0..len])) {
            std.debug.print("Valid\n", .{});
            counter += 1;
            continue :reportLoop;
        }
        for (0..len) |skip| {
            for (0..len - 1) |i| {
                const offset: usize = if (i < skip) 0 else 1;
                input[i] = user_input_u32[i + offset];
            }
            std.debug.print("skip: {}  len: {}\n", .{ skip, len });
            if (subroutine(input[0 .. len - 1])) {
                std.debug.print("Valid\n", .{});
                counter += 1;
                continue :reportLoop;
            }
        }
        std.debug.print("Invalid\n", .{});
    }

    try stdout.print("No. valid: {}\n", .{counter});
}
