---
title: A jump into ROM traces the RAM under it, even where that RAM holds the program's data
status: open
priority: medium
labels: enhancement
---

Seen disassembling `bigmac.vsf` from scratch, starting from the skeleton `--init` writes. The snapshot was taken with `$01 = $35` (BASIC and the KERNAL out), so the skeleton includes only `c64_zeropage.flo`, `c64_system.flo` and `c64_io.flo`, not `c64_kernal.flo`. The IRQ handler at `$c543`, though, banks the KERNAL back in (`jsr $c494`) and ends with `jmp $ea31`, the KERNAL's IRQ routine. Deflower follows that jump into the RAM under the KERNAL, which holds the copied music patterns (`$e800-$ea52`), and decodes them as code (`warning: $ea51: the instruction runs into data at $ea52`).

Declaring `$e800-$ea52 byte music_patterns_2` stops the decoding, but then the jump is reported as a flow into data (`warning: $c569: jmp $ea31 (lEA31) goes into data`), and the target can't be named `kernal_irq`: it is both a KERNAL entry point and a byte of the program's data, and a `.flo` file can say only one of the two.

[0066](0066-snapshot-rom-areas-are-not-in-the-image.md) settled ROM visibility with "the user declares it" through `include c64.flo`. That breaks down here in two ways:
- `--init` picks the includes from the snapshot's `$01`, which is only right for the code that ran when the snapshot was taken.
- Including `c64_kernal.flo` doesn't help where the program's own data lines cover the same addresses: own lines win, so the KERNAL's labels and virtual area are gone from exactly the spot the jump goes to.

Want: a way to say that a flow target is outside the image (ROM, another bank) and is not traced, while the RAM at the same addresses keeps its own areas and labels. Options:
1. **An external entry line**, e.g. `$ea31 extern kernal_irq`: the trace stops at the target, the operand prints the name, and the RAM area there is untouched. Simple; it is per target, not per banking state.
2. **Per-routine banking**, as in [0069](0069-one-label-per-address-ignores-banking.md): a code range runs with the KERNAL in, and its operands resolve against the KERNAL's labels instead of the RAM's.
3. **`--init` includes the ROM labels anyway** when a vector or the code jumps to a known ROM entry point, so the case above is at least visible in the skeleton.

Done when: `bigmac` from a fresh skeleton prints `jmp kernal_irq` with no warning, while `$e800-$ea52` stays the program's data, and the chosen way is documented in `Flo.g4`'s format comment.
