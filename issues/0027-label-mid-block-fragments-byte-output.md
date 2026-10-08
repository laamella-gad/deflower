---
title: A label in the middle of a data block breaks up its .BYTE output
status: done
labels: bug
---

A label landing on an address in the middle of an otherwise-contiguous data block (e.g. a 1000-byte array with a few named bytes inside it) forces the output to restart a fresh `.BYTE` line at that address - and wedges a blank-line-separated label in right before it - even though the whole block is still one logical run of bytes that should read as one dump.

Concrete evidence from the existing `squirm` fixture (`src/test/resources/squirm/expected.asm:2844`), three labels landing inside what is otherwise one contiguous run of note-table bytes:

```
voice_1_notes:		.BYTE	$00

data:		.BYTE	$14, $1E, $28, $32, $3C, $46, $50, $5A, $64, $00, $00, $00, $00, $00, $00, $00
		.BYTE	$00, $00, $00, $00, $00, $00, $0A, $14, $1E, $28, $32, $3C, $46, $50, $5A, $00
		...
		.BYTE	$50, $5A

data:		.BYTE	$64

voice_2_notes:		.BYTE	$0A, $14, $0A, $14, $0A, $14, $0A, $14, ...
```

That's one run of bytes, chopped into four separate `.BYTE` groups (with blank lines between) purely because three of its addresses happen to carry a label. There's also a smaller cosmetic bug visible in the same output: the label and its first `.BYTE` line land glued together on one line (`voice_1_notes:\t\t.BYTE\t$00`, no newline between the label and the data), instead of the data starting on its own line underneath.

Cause: `ResultWriter.write`'s per-address loop (`ResultWriter.java`) always calls `AssemblyFileFormat.printAnnotation` (which does `considerReOrg` + two `newLine()`s) whenever an address has a label, *before* calling `AssemblyFileFormat.print(DataArea, ...)` for that same address - regardless of whether that address is still inside the same data area as the byte before it. `print(DataArea, ...)` only starts a new `.BYTE`/`.WORD`/etc. line when the area's *type* changes from the previous one (`block.type != ((DataArea) lastArea).type`), so a label alone is enough to force the break via `printAnnotation`'s own newlines, but nothing then starts the data back up on a line of its own afterward.

Done when: a label (or comment) on an address inside a still-contiguous same-kind data run doesn't restart the `.BYTE`/`.WORD`/etc. tabular grouping - the dump keeps running as one block, with the label's address noted some other way (e.g. a comment-style marker, or the label on its own line immediately followed by the data continuing beneath it) rather than splitting the run and/or gluing the label and data onto one line. The three squirm labels above (`voice_1_notes`, the two `data` labels, `voice_2_notes`) are a ready-made test case: whatever the new output looks like, it should read as one continuous byte dump with the labels visibly marking their addresses, not four separate blocks.

**Fixed.** `AssemblyFileFormat.printAnnotation` (`ResultWriter.java`) now takes the address's `currentArea` and checks whether it continues the same contiguous, same-type, non-`isSystem` `DataArea` run as the previously-printed address (`lastArea.type == currentArea.type && lastArea.lastOccupiedAddress == address - 1`). When it does, the blank-line separator is skipped and the label (or comment) is printed on its own line, letting `print(DataArea, ...)` start a fresh `.BYTE`/`.WORD` row directly beneath it - no blank line, no gluing. A label that *isn't* continuing a run (first thing after a gap/reorg, or a type change - e.g. two unrelated same-type single-byte cells separated by an actual memory hole, like `jiffy_timer` / `last_key_pressed` in squirm) keeps the old blank-line/glued formatting, since real "different declarations, coincidentally same type" cases shouldn't be merged visually. Code labels (`InstructionArea`) are untouched - this is scoped to data blocks only, per the issue title.

Added a minimal dedicated fixture, `midblocklabel` (3+1+2-byte contiguous BYTE arrays, three labels), confirming the exact desired shape:
```
*=$C000

before:
		.BYTE	$11, $22, $33
middle:
		.BYTE	$44
after:
		.BYTE	$55, $66
```

Regenerated and reviewed (snipsert) `squirm/expected.asm` and `zwark/expected.asm`, the two existing fixtures with mid-run labels. Confirmed via diff that every changed line is purely the blank-line removal / label-own-line / `.BYTE` continuation - no label, value, or address changed. The squirm evidence from this issue now reads as one continuous block:
```
voice_1_notes:		.BYTE	$00
data:
		.BYTE	$14, $1E, $28, $32, $3C, $46, $50, $5A, $64, $00, $00, $00, $00, $00, $00, $00
		...
		.BYTE	$50, $5A
data:
		.BYTE	$64
voice_2_notes:
		.BYTE	$0A, $14, ...
```
(`voice_1_notes` itself keeps the old glued single-line style since nothing precedes it in that run - expected, out of scope.)

All 25 tests pass (`mvn -o test`). `comments`, `tcmine`, and the other fixtures were unaffected (no diff).
