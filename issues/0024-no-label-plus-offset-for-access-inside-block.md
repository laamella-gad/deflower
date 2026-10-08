---
title: No "label + offset" for an access that lands inside a larger labeled block
status: open
labels: enhancement
---

Example: `$400 byte[1000] screen` labels the start of screen memory. Code that does `STA $422` (writing into the middle of that block, offset $22) should show up in the output as something like `STA screen + $22`, not a bare `$0422`.

`DataArea.labelFor` (`DataArea.java:18`) already has the offset formatting for this (`"%s + %d", label, offset`), but it can't trigger: `SubjectConfigurer.exitLine` registers an array annotation (`byte[1000] screen`) as `amount` separate one-element `DataArea` objects, each `new DataArea(address + i * sizeInBytes, ...)` (`SubjectConfigurer.java:148`). Every one of those per-element areas has its own `this.address` equal to the element's own address, so `labelFor`'s `offset` is always 0, and the label lookup is `subject.memory[address].label` — which is null for every element except the one actually carrying the `screen` label (the first). So `nameForAddress` (`ResultWriter.java:153`) falls back to raw hex for every address in the block except its first byte.

Done when: an operand address that falls inside a labeled multi-element block resolves to `<block label> + <offset>` (reusing or fixing `DataArea.labelFor`), with a test like the example above (`STA $422` into a `$400 byte[1000] screen` block) asserting the operand prints as `screen + $22` rather than `$0422`.
