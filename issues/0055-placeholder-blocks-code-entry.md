---
title: A jump target inside a placeholder is never traced
status: done
labels: bug
---

`Subject.addPotentialCodeLocation` only pushes a jump, branch or JSR target when no area covers it (`location.area == null`). A placeholder (an untyped range, issue 0031) counts as covering it, so code reached only through a jump into a placeholder is never disassembled. `FlowAnalyser.analyseCodeFlow` itself would decode through a placeholder, and a `code` line in the `.flo` file does reach it, so only targets found by tracing are affected.

Found in issue 0028: zwark's `$9bcc draw_logo` used to be a 1-byte placeholder and printed as `.byte $A2`, although a JSR reaches it. Once untyped single addresses stopped registering an area, it was traced as code.

Fix: push the target when its area is null or a placeholder (`!location.area.isPlaceholder()` otherwise).

Done when: a fixture with a JSR into an untyped range traces the code there, and that range's remaining bytes still print as placeholder data.

## Closing note

`Subject.addPotentialCodeLocation` now pushes a target that no area covers or that a placeholder covers. That also covers fall-through, so code that runs on into a placeholder is traced too, the same way a `code` line already decodes through one.

New fixture `placeholderjump`: a JSR into the untyped range `$c004-$c009` traces `LDA #$01` / `RTS` there, and the two remaining bytes still print as `.byte`. It assembles to the `.prg`.

squirm relied on the old behaviour. Its `JSR $2441` jumps into the operand of the `BNE` at `$2440` (overlapping instructions), and `squirm.flo` used the untyped range `$243e-$243f` as a stop marker so the fall-through trace wouldn't claim those bytes. That marker is now typed: `$243e-$243f byte`. A stop marker has to be deliberate data, because placeholders are meant to be narrowed. squirm's output is unchanged, and no other expectation changed.

46/46 tests green.
