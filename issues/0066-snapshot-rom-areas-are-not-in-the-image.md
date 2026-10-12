---
title: A snapshot's ROM areas are decoded from the RAM underneath
status: done
labels: bug
---

`C64MemModuleHandler` takes the 64K RAM image from a VICE snapshot's `C64MEM` module. The C64's ROMs (BASIC at `$a000-$bfff`, KERNAL at `$e000-$ffff`) and I/O at `$d000-$dfff` are banked over that RAM depending on the CPU port at `$01`, and they aren't in that module. Deflower always decodes the RAM.

Seen in fixture `bigmac`: the IRQ handler ends with `jmp $ea31`, the KERNAL's IRQ routine. Deflower follows it into the RAM under the KERNAL and prints a run of `ora ($01, x)` and an `isc` as if they were code.

Also in `1nvader_snap`, where `$01` is `$37` (all ROMs visible): its `jsr $ffba`, `$ffbd`, `$ffc0` and `$ffd8` (KERNAL SETLFS, SETNAM, OPEN, SAVE) decode the RAM under the KERNAL as `brk` and `isc`.

Which memory is visible depends on `$01` at the moment the code runs, which a single snapshot doesn't say for every routine (the snapshot's own `$01` is only the value when it was taken).

Worse, the visibility isn't fixed for a program at all. Code can write `$01` at any time, banking the ROMs and I/O in and out, so the same address can be ROM in one routine and RAM in the next, and programs move things around: copy a ROM's contents into the RAM under it, or point the VIC at another bank through `$dd00`. Which memory an instruction sees can only be known by following the `$01` writes, which a static trace can't do in general.

Options to decide between:
1. **Let the user declare it.** A `virtual` range in the `.flo` file already stops the trace ("Jumping into non-code area") and names the target, e.g. `$e000-$10000 virtual byte kernal` plus `$ea31 kernal_irq`. Then this is only documentation plus a fixture, but every `.flo` for a program that uses the KERNAL repeats it.
2. **Treat the ROM areas as not loaded by default** (see [0065](0065-trace-stops-at-memory-the-image-does-not-load.md)), with a way to say a program banks them out and uses the RAM.
3. **Load the ROMs** from the snapshot when VICE saved them (its ROM module), or from ROM files, and pick ROM or RAM by `$01`. Most work, and still only right for the `$01` value it uses.

Consequences for the options:
- Option 2 can't pick the areas from the snapshot's `$01`: that value is only right for the code that ran when the snapshot was taken. It would have to be fixed areas, which is wrong for every program that banks the ROMs out.
- Option 3 has the same gap: loading the ROMs doesn't say when they are visible.
- Option 1 is the only one that doesn't guess: the user knows what each part of the program banks in. A shared `c64.flo` ([0078](0078-include-shared-flo-definitions.md)) makes it cheap.
- Finer control means declaring the banking per routine or address range in the `.flo` file, so code there sees ROM, I/O or RAM. That overlaps with [0069](0069-one-label-per-address-ignores-banking.md), where a label can't follow banking either.

Done when: `bigmac`'s `jmp $ea31` no longer decodes the RAM under the KERNAL, and the chosen way is documented in `Flo.g4`'s format comment if it involves the `.flo` file.

## Closing note

Option 1: the user declares what is banked in. The built-in `c64.flo` ([0078](0078-include-shared-flo-definitions.md)) already declares BASIC, I/O and the KERNAL as virtual areas with their labels, so this needed no code. `bigmac.flo` and `1nvader_snap.flo` now `include c64.flo`, like `zwark`, `squirm` and `tcmine`. `Flo.g4`'s format comment says a snapshot holds only RAM, and that the include keeps the trace out of the ROMs.

- `bigmac`: `jmp $ea31` now prints `jmp kernal_irq`, with `kernal_irq = $ea31`, instead of 16 `ora ($01, x)`, an `isc` and a `brk`. Its SID, `$01` and `$a000` operands got names too.
- `1nvader_snap` already declared the KERNAL jump table itself (`$ff00 virtual {`), so only `cpu_port` and `io_status` changed.

Seen on the way, and an example of [0069](0069-one-label-per-address-ignores-banking.md): `bigmac`'s IRQ handler banks BASIC and the KERNAL out (`lda cpu_port`, `and #$fd`), and `lC2D8` then reads `lda $a000, y`, which is the RAM under BASIC. That line now prints as `lda basic_cold_start_vector, y`, which is wrong for that code. A label of `bigmac.flo`'s own at `$a000` would fix it there.
