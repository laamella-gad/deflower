---
title: First label of a run still glues onto its .BYTE line, inconsistent with the rest of the run
status: done
labels: bug
---

After issue 0027's fix, a label that *continues* a contiguous same-type run gets its own line, with the `.BYTE` data starting fresh underneath. But the *first* label of such a run keeps the old glued formatting (label and its first `.BYTE` on one line), because `continuesRun` is false for it (nothing of the same type/contiguous precedes it - `lastArea` is null or a different area at that point).

Visible in `squirm/expected.asm` (around line 16):

```
new_loc_lo:		.BYTE	$E0
new_loc_hi:
		.BYTE	$05
tmp_loc_lo:
		.BYTE	$E0
tmp_loc_hi:
		.BYTE	$05
```

`new_loc_lo`, `new_loc_hi`, `tmp_loc_lo`, `tmp_loc_hi` are four single-byte cells in one contiguous BYTE run. The first one (`new_loc_lo`) is glued to its `.BYTE $E0`; the other three each get their own line above their data. Same kind of label, same kind of run, two different formats depending only on whether something of the same type happened to precede it.

Cause: `AssemblyFileFormat.printAnnotation`'s `continuesRun` check (`ResultWriter.java`, added in issue 0027) only looks backward (`lastArea` same type + contiguous). The first label of a run has no such predecessor, so it falls into the `else` branch and keeps the pre-0027 glued-line behavior, which was never revisited for consistency once the "continuing" case got its own-line treatment.

Done when: the first label of a run and every later label in that same run are formatted the same way - either all glued, or (more likely, matching 0027's intent) all on their own line with the data starting underneath.

## Resolution

Per-request addition: glue only when the label's data run is a single value; several values get their own line. This now applies uniformly to the first label of a run and every later one - no more special-casing the first label.

`AssemblyFileFormat.printAnnotation` (`ResultWriter.java`) gained `isSingleValueRun(address, block, subject)`: looks forward from the label's address and returns true if the run breaks after exactly one value (next address has its own label/comment, isn't the same kind of data, or doesn't exist). The decision to add a newline after the label is gated on `sameKindAsPrevious` (same `DataArea` type as `lastArea`, not necessarily contiguous) `&& !isSingleValueRun(...)`.

Found and fixed a double-newline regression along the way: `print(DataArea, ...)` already inserts its own newline whenever the area type changes from `lastArea`. My first attempt decided the label's newline purely from `isSingleValueRun`, so a multi-value run starting right after a type change (e.g. code -> data) got two newlines - caught by `secondDeflowerLineStartsAFreshIndependentRun` (`multi` fixture), which showed a spurious blank line before `marker_b:`. Fixed by gating the label's own newline on `sameKindAsPrevious`: `printAnnotation` only adds it when `print(DataArea, ...)` is *not* going to add its own (same type as before), so exactly one of the two mechanisms is ever responsible for a given break.

Verification:
- `mvn -o test`: 25/25 green.
- `squirm/expected.asm`: `new_loc_lo`/`new_loc_hi`/`tmp_loc_lo`/`tmp_loc_hi` (the issue's original evidence) all now glued identically. `voice_1_notes` and the second `data:` label (both single-value) now glued too; the two genuinely multi-value runs (`data:` 98 bytes, `voice_2_notes`) stay own-line.
- `zwark/expected.asm`: reviewed in full - single-value labels (`sprite_x_high_bits`, `joystick_state`, `sprite_coll_state`, `vic_sprite_x_high_bits`) glued; multi-element arrays (`sprite_pointers`, `table_with_timed_stuff`, `table_with_timers`, `vic_sprite_colors`, `vic_color_ram`) own-line. All changes were formatting only, no label/value/address regressions.
- `blockoffset/expected.asm`, `datatypes/expected.asm`: unaffected by the corrected fix (checked out to baseline, reran, passed unchanged).
- New fixture `midblocklabel` (added for issue 0027) confirms the combined rule: `before`/`after` (3/2 elements, multi-value) own-line; `middle` (1 element, single-value, immediately followed by `after`'s own label) glued.
