---
title: Investigate 6502bench SourceGen for features worth adopting
status: open
priority: low
labels: research
---

[6502bench SourceGen](https://6502bench.com/) is an interactive 6502 disassembler with a code-tracing model close to deflower's (start from entry points, follow control flow, mark the rest as data by hand) and 64tass among its output targets. Worth reading through for ideas (see also the range-end comparison in [0007](0007-range-end-off-by-one.md)).

Starting points, from memory, to verify against its manual:
- Operand formatting: choosing how an operand is shown (hex, decimal, symbol, the high or low part of a symbol; related to [0034](0034-support-hi-lo-byte-extraction-operators.md)).
- Platform symbol files: ready-made labels for system ROM and I/O addresses (for the C64: KERNAL, VIC-II, SID).
- Visualizations of bitmaps and sprites (related to [0020](0020-pretty-data-formats.md)).
- Extension scripts that handle inline data after a `JSR`, and other code idioms.
- Local variable tables for zero page, and project notes.
- Automatic string detection and how it picks the string directive (related to [0047](0047-null-and-ptext-string-directives.md)).
- How it keeps generated output reassembling to the original bytes for each assembler.

Done when: a short list of SourceGen features worth having, each either filed as a new issue or linked to an existing one, with the rest dismissed in a sentence each.
