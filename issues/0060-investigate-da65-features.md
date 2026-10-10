---
title: Investigate da65 for features worth adopting
status: open
priority: low
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
