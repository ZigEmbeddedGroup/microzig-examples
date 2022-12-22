const microzig = @import("microzig");
const chip = microzig.chip;
const regs = chip.registers;
const cpu = microzig.cpu;

// The LED PIN we want to use
const PA1 = chip.parsePin("PA1");

pub fn main() !void {
    // above can also be accomplished with microzig with:
    chip.gpio.setOutput(PA1);

    while (true) {
        // Read the current state of the gpioa register.
        var gpioa_state = regs.GPIOA.ODR.read();

        // we can use this to invert the current state easily
        regs.GPIOA.ODR.modify(.{ .ODR1 = ~gpioa_state.ODR1 });

        // Burn CPU cycles to delay the LED blink
        var i: u32 = 0;
        while (i < 600000) : (i += 1)
            cpu.nop();
    }
}
