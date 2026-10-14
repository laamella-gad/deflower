---
title: A jump into ROM traces the RAM under it, even where that RAM holds the program's data
status: done
labels: enhancement
---

Seen disassembling `bigmac.vsf` from scratch, starting from the skeleton `--init` writes. The snapshot was taken with `$01 = $35` (BASIC and the KERNAL out), so the skeleton includes only `c64_zeropage.flo`, `c64_system.flo` and `c64_io.flo`, not `c64_kernal.flo`. The IRQ handler at `$c543`, though, banks the KERNAL back in (`jsr $c494`) and ends with `jmp $ea31`, the KERNAL's IRQ routine. Deflower follows that jump into the RAM under the KERNAL, which holds the copied music patterns (`$e800-$ea52`), and decodes them as code (`warning: $ea51: the instruction runs into data at $ea52`).

Declaring `$e800-$ea52 byte music_patterns_2` stops the decoding, but then the jump is reported as a flow into data (`warning: $c569: jmp $ea31 (lEA31) goes into data`), and the target can't be named `kernal_irq`: it is both a KERNAL entry point and a byte of the program's data, and a `.flo` file can say only one of the two.

[0066](0066-snapshot-rom-areas-are-not-in-the-image.md) settled ROM visibility with "the user declares it" through `include c64.flo`. That breaks down here in two ways:
- `--init` picks the includes from the snapshot's `$01`, which is only right for the code that ran when the snapshot was taken.
- Including `c64_kernal.flo` doesn't help where the program's own data lines cover the same addresses: own lines win, so the KERNAL's labels and virtual area are gone from exactly the spot the jump goes to.

Want: a way to say that a flow target is outside the image (ROM, another bank) and is not traced, while the RAM at the same addresses keeps its own areas and labels. Options:
1. **An external entry line**, e.g. `$ea31 extern kernal_irq` (became `banked`, see below): the trace stops at the target, the operand prints the name, and the RAM area there is untouched. Simple; it is per target, not per banking state.
2. **Per-routine banking**, as in [0069](0069-one-label-per-address-ignores-banking.md): a code range runs with the KERNAL in, and its operands resolve against the KERNAL's labels instead of the RAM's.
3. **`--init` includes the ROM labels anyway** when a vector or the code jumps to a known ROM entry point, so the case above is at least visible in the skeleton.

## How other disassemblers handle it

Checked on 2026-10-14. None of them has a ready answer for "a flow target is in ROM, while the RAM under it holds the program's data", but the pieces exist:

| Tool | Flow into an address outside the program | Two things at one address |
|---|---|---|
| [da65](https://cc65.github.io/doc/da65.html) | No tracing: `RANGE` lines say what is code. `LABEL` names any address, inside the input or not. | One map, `$0000-$ffff`; banks are disassembled in separate runs. One label per address. |
| [6502bench SourceGen](https://6502bench.com/sgmanual/intro-details.html) | Traces only inside the file. An operand pointing outside gets a platform (ROM) or project symbol by value. Code start and stop points can be tagged by hand; a branch into inline data is ignored. | Address regions can give the same address to different parts of the file, and an operand's target is resolved from where the instruction is. Regions can [disallow inbound and outbound resolution](https://git.applefritter.com/6502/6502bench/commit/d4c481839e174a273129a88ef183934ee13b4218). An operand's symbol can be set by hand, per instruction, to anything. |
| Ghidra | Overlay blocks for the other occupants of an address range; references between overlay and base space are added by hand. | [Discussion 9349](https://github.com/NationalSecurityAgency/ghidra/discussions/9349) proposes bank-aware operand resolution (a context register for the bank, a map from range and bank to memory, separate read and write targets) and names the C64 processor port as a case it doesn't handle today. Not shipped. |
| [Regenerator 2000](https://regenerator2000.readthedocs.io/en/latest/analysis/) | A `jsr`/`jmp` outside the program gets an `e_xxxx` label, or a system label (KERNAL, BASIC), which wins over auto labels. An address can be excluded from analysis. | Not described. |

What carries over:
- **Per-instruction operand override** (SourceGen): the user says what one operand names. Covers this issue and [0069](0069-one-label-per-address-ignores-banking.md) option 1, but has to be repeated at every call site.
- **A label for the outside, by value** (SourceGen platform symbols, da65 `LABEL`, Regenerator system labels): deflower's included labels already are this, except that the program's own lines at the same address win over them.
- **Banked address spaces** (SourceGen regions, Ghidra overlays and the RFC): the general answer, and [0069](0069-one-label-per-address-ignores-banking.md) option 2. The tools that have it needed a whole model of regions and resolution rules for it.
- **Stop points** (SourceGen): tracing stops at a marked address. Nothing else changes.

That points at option 1, scoped to flow: `$ea31 banked kernal_irq` names the target for `jmp`/`jsr`/branches only, which stop there. Reads and writes of `$ea31` still resolve to the RAM's own area and label, which is right for a write on the C64 (it always reaches the RAM), and for a read made with the KERNAL out. A read made with the KERNAL in is the [0069](0069-one-label-per-address-ignores-banking.md) case and stays open.

Done when: `bigmac` from a fresh skeleton prints `jmp kernal_irq` with no warning, while `$e800-$ea52` stays the program's data, and the chosen way is documented in `Flo.g4`'s format comment.

## Closing note

Done as option 1, with the keyword `banked` (not `extern`: what is outside the image is banked in, ROM or I/O alike): `<address> banked <label>`, documented in `Flo.g4`.
- A `jsr`, `jmp`, branch or `rta` to the address prints the label and isn't traced. `.addr` values and an address setup's `#<`/`#>` use it too when the RAM has no label on the address itself. Reads and writes keep the RAM's name: reading a KERNAL routine is rare.
- The names print as `label = $addr` defines at the top of the output, with the line's comment and who calls or jumps to them; an included one only when used.
- A banked line takes only an address and a label. It is applied before all other lines, so an `rta` line can't trace into the RAM first. A code line of the file itself, or a label of its own with the same name (like 1nvader's virtual KERNAL jump table), wins over an included banked line; a code line is an error next to a banked line of its own (`Subject.checkBankedCodeEntries`). An included label line with the banked name at the same address is dropped.
- `bigmac.flo` now has `$ea31 banked kernal_irq`: `jmp kernal_irq` with no warning, `$e800-$ea52` stays `voice_1_parameters`.
- Snippets: `short/banked.txt`, `short/invalid/bankedwithtype.txt`, `short/invalid/bankedcodeentry.txt`.

The entry points in the built-in `c64_kernal.flo`/`c64_basic.flo` are banked lines now, so their names print as defines at the top of every output that uses them. A read made with the KERNAL banked in stays [0069](0069-one-label-per-address-ignores-banking.md).
