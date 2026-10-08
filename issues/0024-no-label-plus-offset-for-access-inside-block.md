---
title: No "label + offset" for an access that lands inside a larger labeled block
status: done
labels: enhancement
---

Example: `$400 byte[1000] screen` labels the start of screen memory. Code that does `STA $422` (writing into the middle of that block, offset $22) should show up in the output as something like `STA screen + $22`, not a bare `$0422`.

`DataArea.labelFor` (`DataArea.java:18`) already has the offset formatting for this (`"%s + %d", label, offset`), but it can't trigger: `SubjectConfigurer.exitLine` registers an array annotation (`byte[1000] screen`) as `amount` separate one-element `DataArea` objects, each `new DataArea(address + i * sizeInBytes, ...)` (`SubjectConfigurer.java:148`). Every one of those per-element areas has its own `this.address` equal to the element's own address, so `labelFor`'s `offset` is always 0, and the label lookup is `subject.memory[address].label` — which is null for every element except the one actually carrying the `screen` label (the first). So `nameForAddress` (`ResultWriter.java:153`) falls back to raw hex for every address in the block except its first byte.

Done when: an operand address that falls inside a labeled multi-element block resolves to `<block label> + <offset>` (reusing or fixing `DataArea.labelFor`), with a test like the example above (`STA $422` into a `$400 byte[1000] screen` block) asserting the operand prints as `screen + $22` rather than `$0422`.

Fixed in `DataArea.labelFor`: since an array annotation still registers one single-element `DataArea` per index (left as-is — only the per-address lookup changed), a mid-block address walks backward through same-type, same-`isSystem` `DataArea`s until it finds one with a label (or the run breaks), then formats `label + $<offset>` (hex, matching the issue's own example and the codebase's general hex convention; the pre-existing `%d` decimal format was never reachable). New fixture `blockoffset/` (`byte[48] screen` at $400, `STA $422` into it) asserts `STA screen + $22`.

This also fires on the existing `squirm` and `zwark` fixtures, which both index into real labeled arrays - their `expected.asm` files were regenerated (delete + rerun once + review, per the "always use snipsert" rule) and reviewed line-by-line; every change is a bare hex address turning into `label + $offset` (e.g. `STA $0428, Y` -> `STA vic_screen + $28, Y`), none are regressions.

Known complexity tradeoff (not addressed here, see discussion): this patches `labelFor` with an O(n) backward scan rather than fixing the root cause, which is that an array is modeled as N separate one-element `Area`s instead of one `Area` spanning the whole block. A single spanning `Area` would make offset lookup O(1) and remove the need for the "walk backward through same-kind neighbors" heuristic entirely, but it would require reworking how `AssemblyFileFormat.print(DataArea, ...)` groups elements into output lines, which currently depends on each element being its own `Area`. Left as a possible future refactor.
