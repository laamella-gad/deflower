---
title: Emit a label inside a larger area as an address define, not inline
status: done
labels: enhancement
---

Issue 0027 stopped a mid-block label from fragmenting the `.BYTE`/`.WORD` dump into separate blank-line-separated groups, but the label still interrupts the output: it's printed as its own line, splitting the run into several `.BYTE` statements around it (`before:` / `.BYTE ...` / `middle:` / `.BYTE ...` / `after:` / `.BYTE ...` instead of one unbroken dump).

A cleaner fix: when a label's address falls strictly inside a larger already-declared area (not at its start), don't print the label inline at all. Instead emit it elsewhere as a plain address define - e.g. `label = $1234` (or whatever the assembler's equivalent of an `EQU`/constant assignment is) - so the big area's `.BYTE`/`.WORD` dump stays one single, fully uninterrupted run, and the label is still resolvable (code elsewhere referencing that address, e.g. `LDA label`, still works via `DataArea.labelFor`/`nameForAddress` in `ResultWriter.java`) even though it no longer appears next to the byte it names.

This only applies to a label landing *inside* an area (not at an area's own first address, where the label legitimately introduces the block and should stay as-is).

Done when: a label inside a larger area (the `squirm` `voice_1_notes`/`data`/`data`/`voice_2_notes` run from issue 0027 is the ready-made test case) no longer appears inline at all - the area's data prints as one unbroken run - and the label is instead emitted as a standalone address define, resolvable the same way any other label is.

Also cover the narrower case of a label landing inside a single `word`/`dword`/`pointer` area - on its second (or third/fourth) byte, not at the area's own start address. `squirm.flo`'s `word_1_048e` (a `word` at `$2648`) has an auto-generated `_2649_DATA` label sitting on its own second byte ($2649): since `print(DataArea, ...)` only emits output at an area's own start address, nothing ever prints at `$2649` for the word itself, so a label landing there is even more clearly a case for "emit as an address define elsewhere" - there's no run to interrupt (a `word`/`dword` is one value, not a dump of many), but printing it inline still produced a real formatting bug (the label glued onto the next, unrelated label/comment with no line break - fixed as a formatting-layer patch in `ResultWriter.printAnnotation`, but the define-instead-of-inline approach this issue proposes would sidestep the whole class of bug instead of patching around it).

Note from issue 0015: printing a label inside a `word` on its own line is not only cosmetic, it assembles the label at the wrong address. In squirm, `_2649_DATA:` (inside the word at `$2648`) was printed after that word, so 64tass placed it at `$264A`, and the seven instructions that referred to it assembled with the wrong operand. 0015 avoids that case by not auto-labelling an address that already resolves as `label + offset`. A user label inside a word would still hit it.

## Closing note

Decided rules:

- **The unit is the declared array**, one `.flo` line, not a run of same-type data. A label at the start of an array stays `label:`. A label on a later element is printed as `label = $XXXX` after the array, so the array's dump stays unbroken. A first attempt merged whole same-type runs; that ran zwark's six sprites and the strings fixtures' separate strings together, and was dropped.
- **Inside a word/dword/pointer or on an instruction's operand byte**, the label becomes a define after the element or instruction. It now gets its exact address; the inline label used to assemble one byte too far.
- **On memory no area covers**, the label is a define in place. partialoverlap's `entry:` no longer makes an empty origin block (left over from [0054](0054-empty-labels-on-uncovered-memory.md)).
- **A single address without a type registers no area.** Before, it was a 1-byte placeholder, which conflicted with any typed area under it, so a label inside `$0400 byte[1000] screen` couldn't be written at all. Now it only names or comments the address. An untyped range is still a placeholder. `virtual` on such a line is an error, since there is nothing to reserve.

Code: `ResultWriter.write` defers labels that continue the previous address (`continuesPrevious`: same area, or the next element of the same array via `Subject.continuesArray`) and prints them with `AssemblyFileFormat.printDefines` when the array or instruction ends. `Subject.annotate` returns early for an untyped single address. The grammar comment and CLAUDE.md describe both rules.

Tests: new fixture `arraylabel` (a label inside a `byte[8]` and inside a `word`, assembles to the `.prg`), and `reportsVirtualOnPlainAddress`. `midblocklabel` is unchanged: its labels each start their own array.

Expectations regenerated:
- squirm: auto-labels inside unnamed arrays move into defines. Same bytes.
- partialoverlap: `entry = $C000`.
- zwark: its nine untyped single-address lines stop being 1-byte placeholders. The defines for `logo0`-`logo4`, `joystick_state`, `sprite_coll_state` and `init_sprite_coords` replace 8 one-byte dumps. `draw_logo` is now traced as code (120 more bytes): its placeholder used to block the JSR target, see [0055](0055-placeholder-blocks-code-entry.md). Checked against the RAM image: every assembled byte matches, except the same 6 mismatches the previous expectation already had.

45/45 tests green.
