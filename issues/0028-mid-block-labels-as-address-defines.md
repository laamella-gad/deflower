---
title: Emit a label inside a larger area as an address define, not inline
status: open
labels: enhancement
---

Issue 0027 stopped a mid-block label from fragmenting the `.BYTE`/`.WORD` dump into separate blank-line-separated groups, but the label still interrupts the output: it's printed as its own line, splitting the run into several `.BYTE` statements around it (`before:` / `.BYTE ...` / `middle:` / `.BYTE ...` / `after:` / `.BYTE ...` instead of one unbroken dump).

A cleaner fix: when a label's address falls strictly inside a larger already-declared area (not at its start), don't print the label inline at all. Instead emit it elsewhere as a plain address define - e.g. `label = $1234` (or whatever the assembler's equivalent of an `EQU`/constant assignment is) - so the big area's `.BYTE`/`.WORD` dump stays one single, fully uninterrupted run, and the label is still resolvable (code elsewhere referencing that address, e.g. `LDA label`, still works via `DataArea.labelFor`/`nameForAddress` in `ResultWriter.java`) even though it no longer appears next to the byte it names.

This only applies to a label landing *inside* an area (not at an area's own first address, where the label legitimately introduces the block and should stay as-is).

Done when: a label inside a larger area (the `squirm` `voice_1_notes`/`data`/`data`/`voice_2_notes` run from issue 0027 is the ready-made test case) no longer appears inline at all - the area's data prints as one unbroken run - and the label is instead emitted as a standalone address define, resolvable the same way any other label is.
