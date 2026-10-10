---
title: A label-only address gives no "label + offset" for the bytes after it
status: open
priority: low
labels: enhancement
---

A single address with no type is only a label: it registers no area. So an operand at that address prints as the label, but an operand one byte further resolves through whatever area covers that byte, not through the label.

Seen in fixture `3dgolf_snap`. Tables indexed from 1 are read through a base address just before the table:

```
		asl
		tax
		lda $93f3, x
		sta pointer_08
		lda $93f4, x
		sta pointer_08 + $1
```

`hole_shapes` is the word table at `$93f5`, and `$93f3`/`$93f4` are the last two bytes of `terrain_93bd`. With `$93f3 hole_shapes_base` in the `.flo` file, the output is:

```
		lda hole_shapes_base, x
		sta pointer_08
		lda terrain_93bd + $37, x
		sta pointer_08 + $1
```

The second load should be `hole_shapes_base + $1`. The same happens with `hole_positions_base` (`$942b`), read as `+ $0` to `+ $3`, which print as `hole_positions_base` and `pointers_9421 + $b`/`$c`/`$d`.

Fixture `3dgolfpic_snap` has a variant where the base lies inside an instruction: the decruncher reads `decrunch_table` (`$01a6`) through `lda $01a5, x`, and `$01a5` is the high byte of the `jmp show_picture` operand before the table. `$01a5 decrunch_table_base` only produces the define `decrunch_table_base = $01a5`; the operand stays `$01a5`.

Can't be fixed in the `.flo` file: the base's bytes belong to the area before the table, so a typed base would conflict with it.

Options:
1. **A width on a label-only line**, e.g. `$93f3 hole_shapes_base[2]`: operands in that range resolve to the label plus an offset, without registering an area.
2. **Write the operand as an offset from the table**, e.g. `hole_shapes - $2` for `$93f3,x` and `hole_shapes - $1` for `$93f4,x`. That needs a way to say which table an operand belongs to (a per-operand override, as in [0069](0069-one-label-per-address-ignores-banking.md) option 1).
3. **Prefer a nearby label over the covering area**: an operand within a few bytes after a label-only address uses that label. Automatic, but guesses.

Done when: `3dgolf_snap`'s loads from `$93f4,x` and `$942c-$942e,x` print relative to the base label (or the table), and the way to ask for it is documented in `Flo.g4`'s format comment if it involves the `.flo` file.
