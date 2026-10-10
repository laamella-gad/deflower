---
title: A snapshot's ROM areas are decoded from the RAM underneath
status: open
priority: medium
labels: bug
---

`C64MemModuleHandler` takes the 64K RAM image from a VICE snapshot's `C64MEM` module. The C64's ROMs (BASIC at `$a000-$bfff`, KERNAL at `$e000-$ffff`) and I/O at `$d000-$dfff` are banked over that RAM depending on the CPU port at `$01`, and they aren't in that module. Deflower always decodes the RAM.

Seen in fixture `bigmac`: the IRQ handler ends with `jmp $ea31`, the KERNAL's IRQ routine. Deflower follows it into the RAM under the KERNAL and prints a run of `ora ($01, x)` and an `isc` as if they were code.

Also in `1nvader_snap`, where `$01` is `$37` (all ROMs visible): its `jsr $ffba`, `$ffbd`, `$ffc0` and `$ffd8` (KERNAL SETLFS, SETNAM, OPEN, SAVE) decode the RAM under the KERNAL as `brk` and `isc`.

Which memory is visible depends on `$01` at the moment the code runs, which a single snapshot doesn't say for every routine (the snapshot's own `$01` is only the value when it was taken).

Options to decide between:
1. **Let the user declare it.** A `virtual` range in the `.flo` file already stops the trace ("Jumping into non-code area") and names the target, e.g. `$e000-$10000 virtual byte kernal` plus `$ea31 kernal_irq`. Then this is only documentation plus a fixture, but every `.flo` for a program that uses the KERNAL repeats it.
2. **Treat the ROM areas as not loaded by default** (see [0065](0065-trace-stops-at-memory-the-image-does-not-load.md)), with a way to say a program banks them out and uses the RAM.
3. **Load the ROMs** from the snapshot when VICE saved them (its ROM module), or from ROM files, and pick ROM or RAM by `$01`. Most work, and still only right for the `$01` value it uses.

Done when: `bigmac`'s `jmp $ea31` no longer decodes the RAM under the KERNAL, and the chosen way is documented in `Flo.g4`'s format comment if it involves the `.flo` file.
