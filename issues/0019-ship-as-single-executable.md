---
title: Project should ship as a single executable, not a Java jar
status: superseded
labels: enhancement
---

There is no exec plugin configured and no runnable artifact; running the tool means launching `Deflower.main` from an IDE or hand-assembling a classpath (see CLAUDE.md Commands). For the suggested watch-and-rerun workflow, a plain double-clickable/CLI binary would be much friendlier than a Java jar.

Options: a shaded/fat jar wrapped in a launcher script, or a native image (e.g. GraalVM `native-image`) producing a real single-file executable.

Done when: `mvn -o package` (or similar) produces one artifact that can be run directly (`./deflower squirm/squirm.flo`), with no separate classpath assembly or `java -cp ...` step.

## Closing note

Superseded by issue 0059 (convert the whole project to Nim). Nim compiles to a native single-file executable, so the conversion delivers this without a fat jar or GraalVM.
