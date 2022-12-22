const std = @import("std");
const microzig = @import("microzig/src/main.zig");
const ziglibc = @import("lib/ziglibc/ziglibcbuild.zig");

pub fn build(b: *std.build.Builder) void {
    const backing = .{
        .chip = microzig.chips.stm32f407vg
    };
    var elf = microzig.addEmbeddedExecutable(
        b,
        "firmware.elf",
        "src/main.zig",
        backing,
        .{},
    );

    // Link the Zig LibC implementation
    var libc = ziglibc.addLibc(b, .{
        .variant = .only_std,
        .link = .static,
        .start = .ziglibc,
        .trace = false,
        .target = microzig.Backing.getTarget(backing),
    });
    libc.install();

    elf.setBuildMode(.ReleaseSmall);
    elf.install();

    const bin = b.addInstallRaw(elf.inner, "firmware.bin", .{});
    const bin_step = b.step("bin", "Generate binary file to be flashed");
    bin_step.dependOn(&bin.step);

    const flash_cmd = b.addSystemCommand(&[_][]const u8{
        "st-flash",
        "write",
        b.getInstallPath(bin.dest_dir, bin.dest_filename),
        "0x8000000",
    });

    flash_cmd.step.dependOn(&bin.step);
    const flash_step = b.step("flash", "Flash and run the app on your STM32 device");
    flash_step.dependOn(&flash_cmd.step);

    b.default_step.dependOn(&elf.inner.step);
    b.installArtifact(elf.inner);
}
