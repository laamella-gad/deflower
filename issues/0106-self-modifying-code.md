---
title: Point out self-modifying code and stop naming the operands it rewrites
status: done
labels: enhancement
---

`bigmac`'s music player rewrites its own operands. `copy_music_data` at `$c400` copies `$9000-$a000` to `$e000`:

```
copy_music_data:
		lda #$90
		sta lC40C + 2
		lda #$e0
		sta dC411
lC40A:
		ldy #$00
lC40C:
		lda unused_9a52 + $5ae, y
		sta untouched_f000, y
dC411 = $c411
		iny
		bne lC40C
		inc lC40C + 2
		inc dC411
```

The operands of `lda` and `sta` show the values they had when the snapshot was taken, after the loop ran (`$a000`, `$f000`), and they get labels for memory that has nothing to do with the code: `unused_9a52 + $5ae` and `untouched_f000`. The latter even made a skeleton range look used. `sta $c1dd` in the player does the same to an `lda $e000, y`. Reading this code, the stores into operands are the main fact, and they only show as `modified by:` cross-references.

Want:
- An instruction whose operand is written by another instruction is marked: a comment on it (`; operand set by copy_music_data`), and the operand prints as a number, not a label, unless a `.flo` line names it.
- The stores into it name the operand: `sta lC40C + 2` could read `sta lC40C_operand + 1` or similar; at least the cross-reference says which instruction is modified.
- A short summary: `--verify` or the map lists the self-modified instructions.

To decide: whether the operand's value at snapshot time should still be followed as a reference at all (it is right for code that only ever has one value, like a patched `jmp`), and how a `.flo` line gives the real range (`$c40c operand $9000-$a000`?).

Done when: `bigmac`'s `copy_music_data` prints its `lda`/`sta` operands as numbers with a comment saying who sets them, and `untouched_f000`/`unused_9a52` aren't referenced from there.

## Closing note

`SelfModificationFinder` runs after the tracing and finds every instruction whose operand bytes another instruction writes or modifies (branch offsets aside: the target is code either way).
- Such an operand prints as a number, with `; operand set by <routine>` after the instruction. It makes no cross-reference and no skeleton warning, and keeps no included name in use; the auto labels only it made are dropped. Decided: the value the image holds isn't a reference, not even for a patched `jmp`.
- `<address> selfmod <label>` (documented in `Flo.g4`) names such an operand anyway: the label, plus or minus the distance to the value the image holds, e.g. `lda voice_1_notes_copy + $1000, y`. The label gets the cross-reference. A line on an instruction without an address operand, or naming no label, is an error; one on an instruction no traced code writes is a warning, since the writer may not be found yet. This covers the "how a `.flo` line gives the real range" question with a base label rather than a range.
- `bigmac`: `copy_music_data` prints `lda voice_1_notes_copy + $1000, y` and `sta voice_1_notes + $1000, y` with the comment, and the `untouched_f000` warning is gone. Selfmod lines keep the player's `voice_N_notes`/`voice_N_parameters` and `block_pages`.
- `1nvader_snap`, `2krace_snap` and `3dgolf_snap` got selfmod lines where the image's value is the meaningful one (`save_highscore`, `invader_row`, `left_road`/`right_road`, `kernal_irq`, `draw_char`). `3dgolf`'s `rotate_N` dispatch jumps stay numbers: `set_direction` picks one of eight. The decruncher pointers in several fixtures lost made-up names like `unused_ed07 + $c` and `untouched_7f92`.
- Snippets: `short/selfmodifying.txt`, `short/invalid/selfmodwithtype.txt`, `short/invalid/selfmodtarget.txt`.

Not done: the stores into an operand still print as before (`sta lC40C + 2`, or a number when the instruction has no label), and no summary of the self-modified instructions in `--verify` or the map. Writes to an opcode byte, and code copied over code, are [0115](0115-code-that-overwrites-instructions.md).
