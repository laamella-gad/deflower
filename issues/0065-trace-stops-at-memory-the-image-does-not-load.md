---
title: Flow analysis decodes memory the loaded image doesn't contain
status: done
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

## Decisions

- **How to record what was loaded.** A `loaded` flag on `MemoryLocation`, set by `Subject.storeAt`. A `.vsf` snapshot sets all 64K; its ROM areas stay [0066](0066-snapshot-rom-areas-are-not-in-the-image.md)'s problem.
- **Behaviour.** A jump, branch or call into memory the image didn't load keeps its label, decodes nothing and prints "Jumping into memory the image doesn't contain: $XXXX". The same for a `.flo` `code` entry there, and for an instruction whose bytes run past the end of the loaded memory.

## Closing note

`MemoryLocation.loaded` is set for the bytes `Subject.storeAt` copies in; a `.vsf` loads all 64K, so snapshots are unchanged. `FlowAnalyser.analyseCodeFlow` stops at a start address that isn't loaded and prints "Jumping into memory the image doesn't contain: $XXXX"; the label the jump, branch or call gave it stays, and prints as a define. `runsIntoExistingArea` also refuses an instruction whose bytes run past the loaded memory (or past `$ffff`).

New fixture `unloaded` covers a `jsr`, a branch and a `.flo` `code` entry outside the `.prg`, and an opcode on the last loaded byte. Its output reassembles to the `.prg` except that last byte, which no area covers. `1nvader`, `2krace`, `3dgolf` and `3dgolfpic` now print `l0100 = $0100` and the like instead of `brk` blocks; no other expectation changed.
