---
title: Model an array annotation as one Area, not one per element
status: open
labels: refactor
---

`SubjectConfigurer.exitLine` registers an array annotation (`byte[48] screen`) as `amount` separate one-element `DataArea` objects, one per index (`SubjectConfigurer.java`, `new DataArea(address + i * sizeInBytes, ...)` in a loop). Only the first element carries the array's label; every other element's own `Area` has no label at all.

That forced `DataArea.labelFor` (fixed in issue 0024) into an O(n) backward walk through memory, address by address, looking for a labeled same-type/same-`isSystem` neighbor, instead of a simple `address - area.address` offset. It works, but it's a workaround for the underlying model, not a fix of it: offset lookup should be O(1), and the walk's "same kind, uninterrupted run" heuristic is more fragile than it needs to be.

The one-per-element registration exists because `AssemblyFileFormat.print(DataArea, ...)` currently depends on each element being its own `Area` to group them into `.BYTE`/`.WORD`/etc. output lines.

Done when: an array annotation registers as a single `DataArea` spanning the whole block (address + element type + count), `DataArea.labelFor` computes the offset directly with no backward scan, and `AssemblyFileFormat.print` groups a spanning area's elements into output lines some other way (e.g. iterating `area.address .. area.address + area.size` by element stride) without relying on per-element `Area` objects. All existing `DeflowerTest` fixtures (especially `blockoffset`, `squirm`, `zwark`, which exercise array offsets) must still pass unchanged.
