---
title: Address range end is off by one
status: invalid
labels: bug
---

Originally filed as: `SubjectConfigurer.exitLine` computes `amount = (addressEnd - address) / size`, which looked wrong assuming `$0800-$080f` means 16 bytes inclusive.

**Closed as invalid.** The range end is deliberately exclusive, not inclusive, and that's required by the real fixtures, not just a style choice. `squirm.flo` has `$35e7-$35e8 data` immediately followed by `$35e8 code colorize_maze`. If the range included `$35e8`, that byte would be claimed as both data and code. Applying the originally proposed `+1` fix made `colorize_maze` stop being traced as code entirely (it hit `Jumping into non-code area`), confirmed by diffing the generated output. The other ranges in the same file (`$2572-$2680`, `$2682-$26ac`, `$26df-$2800`) also line up edge-to-edge only under the exclusive reading. This also matches `enterMul`'s `addressEnd`, which is exclusive by construction.

So the current code is correct, and the fixture data depends on it staying that way. No code change.

## How other tools read a range end

Checked later, to see whether the exclusive end is the usual convention. Disassembler formats mostly use an inclusive end; IDA and the Commodore-native tools use an exclusive one.

| Tool | End | Source |
|---|---|---|
| da65 (cc65's 6502 disassembler; its info file is the closest analogue to `.flo`) | inclusive | [manual](https://cc65.github.io/doc/da65.html): "The end address is inclusive, that means, it is part of the range." |
| 6502bench SourceGen | inclusive | [commit](https://git.applefritter.com/6502/6502bench/commit/2fed19ac47d14c0b24fb669ec34e04e18a44d698): the project file stores inclusive start and end offsets, so an end record can't point past the end of the file. |
| Ghidra | inclusive | [`AddressRange`](https://ghidra.re/ghidra_docs/api/ghidra/program/model/address/AddressRange.html): "a contiguous inclusive set of addresses". |
| IDA Pro | exclusive | [`segment_t`](https://cpp.docs.hex-rays.com/classsegment__t.html): `end_ea` is exclusive, the last byte is at `end_ea - 1`. |
| C64 KERNAL `SAVE` ($FFD8) | exclusive | [KERNAL functions](https://sta.c64.org/cbm64krnfunc.html): "X/Y = End address of memory area plus 1." |
| Classic Commodore monitors | exclusive | [COMPUTE! #87](https://www.atarimagazines.com/compute/issue87/Commodore_Monitor_Commands.php): the save end "is actually one byte beyond the last byte… common to most Commodore monitors." |
| VICE monitor | not established | The [manual](https://vice-emu.sourceforge.io/vice_12.html) only calls a range "two addresses"; no reliable source found either way. |

Exclusive is the minority among disassembler formats, but it is what C64 users know from `SAVE` and the monitors, it lets adjacent ranges share a boundary address (`$35e7-$35e8` then `$35e8 code`), and a range's length is `end - start`. Someone coming from da65 or SourceGen may still read `$0800-$080f` as 16 bytes, which is how this issue was filed; the grammar header spells out "EXCLUSIVE" with an example for that reason. The verdict stands.
