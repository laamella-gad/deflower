---
title: .flo comments are parsed but not carried to the output
status: open
labels: enhancement
---

`Flo.g4` defines `COMMENT` (`;` or `#`) and a `comment` statement, and has a `// TODO add comments to disassembly` note. `SubjectConfigurer` does not override `enterComment`, so comments are dropped.

Done when: comments from the `.flo` file appear in `deflowered.asm` next to the addresses they annotate.
