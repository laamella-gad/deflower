---
title: A label in the middle of a data block breaks up its .BYTE output
status: open
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
