---
title: Investigate da65 for features worth adopting
status: done
labels: research
---

[da65](https://cc65.github.io/doc/da65.html), cc65's 6502 disassembler, is driven by an info file that plays the same role as a `.flo` file: ranges, labels and comments supplied by hand. That makes it the closest existing tool to deflower, and worth reading through for ideas (see also the range-end comparison in [0007](0007-range-end-off-by-one.md)).

Starting points, from memory, to verify against the manual:
- `RANGE` types beyond plain bytes and words: address tables, RTS tables (related to [0038](0038-rta-return-address-table-detection.md) and [0041](0041-user-declarable-address-pointer-type.md)), text tables, and `Skip` for bytes left out of the output.
- `LABEL` with a `SIZE`, and how labels inside a sized label are written.
- `SEGMENT` and `ASMINC` (reading labels from an include file).
- `GLOBAL` options such as the CPU (illegal opcodes, 65C02) and the output layout.
- How comments and label naming are handled.

Done when: a short list of da65 features worth having, each either filed as a new issue or linked to an existing one, with the rest dismissed in a sentence each.

## Closing note

Checked against the manual on 2026-10-14. New issues:
- `DBYTETABLE`, 16-bit values high byte first: [0116](0116-big-endian-words.md).
- `STARTADDR`, `INPUTOFFS`, `INPUTSIZE`, loading a raw binary: [0117](0117-load-raw-binaries.md).
- `UNIT`, a line break every N elements: [0118](0118-data-line-width-by-array-shape.md).
- `ASMINC`, labels from an assembler include file: [0119](0119-import-assembler-symbols.md).
- Comment level 4, each line's address and bytes: [0120](0120-address-and-bytes-comments.md).
- Unnamed labels: [0121](0121-anonymous-labels-for-short-branches.md).

Deflower already has the rest, often in a richer form: `ADDRTABLE`, `RTSTABLE` and `TEXTTABLE` are `addr`, `rta` and `ascii`/`screencode`; `PARAMSIZE` is a typed, named parameter list; a `LABEL` with a `SIZE` is an array with `label + $offset`; `RANGE`/`LABEL` comments are `.flo` comments; `NEWLINEAFTERJMP`/`NEWLINEAFTERRTS` is the blank line after a flow end; illegal opcodes (`6502X`) are decoded; `SKIP` is covered by `export` and `virtual`.

Dismissed:
- The layout options (columns, `LABELBREAK`, page length, form feeds): cosmetic.
- `SEGMENT`: specific to ca65; [0058](0058-disassemble-region-to-separate-asm-file.md) is the nearest deflower need.
- Multi-pass: deflower resolves all labels before printing.
- `-g` debug info and cpp line markers: no use without ca65, and `include` covers splitting a `.flo` file.
- Other CPUs (65C02, 65816, HuC6280, ...): would need support in mpu6502 first; only relevant for [0098](0098-keep-the-disassembler-generic.md).
