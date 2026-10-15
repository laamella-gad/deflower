---
title: Declare a set of parallel arrays in one line
status: open
priority: low
labels: enhancement
---

Games keep per-object state as parallel arrays, one array per property, each as long as the number of objects. `bigmac` has two sets:
- nine `byte[40]` column arrays at `$080c`-`$0974`: `column_active`, `column_flag_index`, `column_timer`, ...;
- twelve `byte[10]` sprite arrays at `$097e`-`$09f6`.

Each array needs its own line with its start address worked out by hand:

```
$097e byte[10] sprite_a
$0988 byte[10] sprite_b
$0992 byte[10] sprite_c
...
$09ec byte[10] sprite_l
```

A typo in one address shifts everything after it, and inserting a forgotten array means renumbering the rest.

Want: one line, or a block, that lays out consecutive arrays of one size, e.g.

```
$097e byte[10] {sprite_a sprite_b sprite_c ... sprite_l}
```

or a block where each line has only the names and the addresses follow from the size. The `{ }` block syntax already exists for offsets ([0035](0035-implement-offset-block-syntax.md)); a block without addresses inside, where each line follows the previous one, would also cover structs and other runs of differently sized fields.

To decide: the syntax, and whether it is one feature ("lines without an address follow the line before") or only for equal-sized arrays.

Done when: the `bigmac` sprite arrays can be declared without writing their addresses, the syntax is documented in `README.md`, and a short snippet covers it.
