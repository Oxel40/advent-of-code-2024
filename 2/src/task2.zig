const std = @import("std");

const State = union(enum) { Start, Started: i32, Increasing: i32, Decreasing: i32, Invalid: i32 };

const Once = union(enum) { Used, Value: State };

const BacktrackError = error{ OnceUsed, StateIsNotInvalid };

const StateMachine = struct {
    prev_state: Once,
    state: State,

    pub fn new() StateMachine {
        return StateMachine{ .prev_state = Once{ .Value = undefined }, .state = State.Start };
    }

    pub fn fetchState(self: StateMachine) State {
        return self.state;
    }

    pub fn backtrack(self: *StateMachine) BacktrackError!void {
        if (self.state != State.Invalid) {
            return BacktrackError.StateIsNotInvalid;
        }
        if (self.prev_state == Once.Used) {
            return BacktrackError.OnceUsed;
        }
        self.state = switch (self.prev_state.Value) {
            State.Started => State{ .Started = self.state.Invalid },
            else => self.prev_state.Value,
        };
        self.prev_state = Once.Used;
    }

    pub fn feed(self: *StateMachine, value: i32) void {
        std.debug.print("{} + {} + {} => ", .{ self.prev_state, self.state, value });
        self.prev_state = switch (self.prev_state) {
            Once.Value => |_| Once{ .Value = self.state },
            Once.Used => Once.Used,
        };

        self.state = switch (self.state) {
            State.Start => State{ .Started = value },
            State.Started => |current| transitionStarted(current, value),
            State.Increasing => |current| transitionIncreasing(current, value),
            State.Decreasing => |current| transitionDecreasing(current, value),
            else => State{ .Invalid = value },
        };

        std.debug.print("{} {}\n", .{ self.prev_state, self.state });
    }

    fn transitionStarted(current: i32, next: i32) State {
        if (current < next) {
            return transitionIncreasing(current, next);
        }
        if (current > next) {
            return transitionDecreasing(current, next);
        } else {
            return State{ .Invalid = next };
        }
    }

    fn transitionIncreasing(current: i32, next: i32) State {
        if (current < next and current + 4 > next) {
            return State{ .Increasing = next };
        } else {
            return State{ .Invalid = next };
        }
    }

    fn transitionDecreasing(current: i32, next: i32) State {
        if (current > next and current - 4 < next) {
            return State{ .Decreasing = next };
        } else {
            return State{ .Invalid = next };
        }
    }
};

pub fn run1() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buf: [255]u8 = undefined;
    var counter: u32 = 0;

    while (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
        if (user_input.len == 0)
            break;

        std.debug.print("\nStart: {s}\n", .{user_input});

        var sm = StateMachine.new();
        var it = std.mem.split(u8, user_input, " ");
        while (it.next()) |x| {
            const value = try std.fmt.parseInt(i32, x, 10);
            sm.feed(value);
            if (sm.fetchState() == State.Invalid) {
                sm.backtrack() catch |err| {
                    std.debug.print("Backtrack failed, {}\n", .{err});
                    break;
                };
                std.debug.print("Successfully backtracked\n", .{});
            }
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

pub fn run2() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buf: [255]u8 = undefined;
    var numbers: [128]u32 = undefined;
    var counter: u32 = 0;

    while (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
        if (user_input.len == 0)
            break;

        std.debug.print("\nStart: {s}\n", .{user_input});

        var len: usize = 0;
        var it = std.mem.split(u8, user_input, " ");
        while (it.next()) |x| {
            const value = try std.fmt.parseInt(u32, x, 10);
            numbers[len] = value;
            len += 1;
        }
        const user_input_u32 = numbers[0..len];

        std.debug.print("{d}\n", .{user_input_u32});

        counter += 1;
    }

    try stdout.print("No. valid: {}\n", .{counter});
}
