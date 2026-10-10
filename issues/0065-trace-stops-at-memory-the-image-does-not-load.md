---
title: Flow analysis decodes memory the loaded image doesn't contain
status: open
priority: medium
labels: bug
---

A `.prg` loads only its own bytes; `Subject` starts with all 64K set to 0 and `PrgReader` overwrites the loaded range. `FlowAnalyser` doesn't know the difference, so a jump outside the loaded range decodes the zeros there as `brk` instructions, which then appear in the output as if they were part of the program.

Seen in the crunched fixtures, whose decrunchers copy themselves to the stack or zero page before jumping there:
- `2krace`: `jsr l0100`, `jmp l013A`, printed as `l0100: brk` and `l013A: brk`;
- `1nvader`: `jsr l0100`, `jmp l0147`;
- `3dgolf`, `3dgolfpic`: `jmp l0116`.

Those addresses hold whatever the decruncher copied there at run time, not zeros.

Want: the analyser treats memory the image didn't load as unknown. A jump or branch there still gets its label (`l0100`), but nothing is decoded, and the output prints the label as a define (`l0100 = $0100`), like other labels on uncovered memory (issue 0054).

To decide:
- **How to record what was loaded.** E.g. a `loaded` flag on `MemoryLocation`, set by `storeAt`. A `.vsf` snapshot sets all 64K (but see [0066](0066-snapshot-rom-areas-are-not-in-the-image.md)).
- **Message.** Print a line like the existing "Jumping into non-code area", e.g. "Jumping into memory the image doesn't contain: $0100".

Done when: the crunched fixtures no longer print `brk` at addresses outside their `.prg`, and a small fixture covers a jump outside the loaded range.
