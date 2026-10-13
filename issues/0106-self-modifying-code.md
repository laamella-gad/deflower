---
title: Point out self-modifying code and stop naming the operands it rewrites
status: open
priority: medium
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
