---
title: Model an array annotation as one Area, not one per element
status: rejected
priority: low
labels: refactor
---

`SubjectConfigurer.exitLine` registers an array annotation (`byte[48] screen`) as `amount` separate one-element `DataArea` objects, one per index (`SubjectConfigurer.java`, `new DataArea(address + i * sizeInBytes, ...)` in a loop). Only the first element carries the array's label; every other element's own `Area` has no label at all.

That forced `DataArea.labelFor` (fixed in issue 0024) into an O(n) backward walk through memory, address by address, looking for a labeled same-type/same-`isSystem` neighbor, instead of a simple `address - area.address` offset. It works, but it's a workaround for the underlying model, not a fix of it: offset lookup should be O(1), and the walk's "same kind, uninterrupted run" heuristic is more fragile than it needs to be.

The one-per-element registration exists because `AssemblyFileFormat.print(DataArea, ...)` currently depends on each element being its own `Area` to group them into `.BYTE`/`.WORD`/etc. output lines.

Done when: an array annotation registers as a single `DataArea` spanning the whole block (address + element type + count), `DataArea.labelFor` computes the offset directly with no backward scan, and `AssemblyFileFormat.print` groups a spanning area's elements into output lines some other way (e.g. iterating `area.address .. area.address + area.size` by element stride) without relying on per-element `Area` objects. All existing `DeflowerTest` fixtures (especially `blockoffset`, `squirm`, `zwark`, which exercise array offsets) must still pass unchanged.

**Rejected after a real attempt.** Implemented the one-`Area`-per-block model (merged `DataArea` spanning the whole array, O(1) `labelFor`, `AssemblyFileFormat.print` grouping by element stride instead of per-element `Area` identity, plus letting a same-kind sub-block overlap a bigger one without `registerBlock` flagging a conflict). It compiled, and most fixtures passed, but `squirm`'s regenerated output broke labels like this:

```
< LDA high_score_screen + $1, X      (expected/old)
> LDA top_line + $A2, X              (new, wrong)
```

`high_score_screen` is declared in `squirm.flo` as a single labeled byte sitting inside a much bigger, unlabeled background block (`top_line`, ~5KB). The code then reads the *next* byte over (`high_score_screen + 1`), which was never separately declared. The old (0024) model resolves this correctly because its backward scan finds the *nearest preceding label*, crossing however many declared-block boundaries it has to - it doesn't care that `high_score_screen` and `top_line` came from two different `.flo` lines, only that they're contiguous same-kind bytes. The same pattern recurs throughout `squirm.flo` (`word_2_048e + $1`, `_2663_DATA + $1`, `snake_pos_tbl_hi + $1`, etc. - some from explicit labels, some from `FlowAnalyser.ensureLabelled`'s auto-naming, which writes directly to a single address's own label regardless of which `Area` happens to cover it).

A single `Area` per declared block can't represent "nearest preceding label, possibly past this block's own declared extent" - that's a label-chain concept, not an address-range concept. Making it work would mean re-deriving each sub-block's *effective* extent (from its own label up to the *next* label, wherever that turns out to be) instead of using the `.flo` file's declared sizes - which is a different, bigger design, and not what this issue asked for. Closing as rejected rather than letting an O(1)-but-wrong lookup replace a correct O(n) one.
