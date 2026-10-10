---
title: A jump target inside a placeholder is never traced
status: open
labels: bug
---

`Subject.addPotentialCodeLocation` only pushes a jump, branch or JSR target when no area covers it (`location.area == null`). A placeholder (an untyped range, issue 0031) counts as covering it, so code reached only through a jump into a placeholder is never disassembled. `FlowAnalyser.analyseCodeFlow` itself would decode through a placeholder, and a `code` line in the `.flo` file does reach it, so only targets found by tracing are affected.

Found in issue 0028: zwark's `$9bcc draw_logo` used to be a 1-byte placeholder and printed as `.byte $A2`, although a JSR reaches it. Once untyped single addresses stopped registering an area, it was traced as code.

Fix: push the target when its area is null or a placeholder (`!location.area.isPlaceholder()` otherwise).

Done when: a fixture with a JSR into an untyped range traces the code there, and that range's remaining bytes still print as placeholder data.
