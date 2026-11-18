---
title: Let a run see the labels of the other runs in the same .flo file
status: open
priority: medium
labels: enhancement
---

A `.flo` file with several `deflower` lines makes independent runs. A program split over files is one program, though: a loader jumps into the main part, a moved helper is called by the main part.

Found in The Write Stuff 128 (`~/dev/c64-productivity/tws128/tws128.flo`): the run for `bb_booter.prg` ends with `jmp $1c52`, the `start` of the next run (`bb_writer.prg`). It prints `jmp l1C52` and warns `goes into memory the image doesn't load`, although the same `.flo` file names `$1c52 start` a few lines further down.

Want: labels on code and data of other runs in the same `.flo` file resolve in a run where that memory isn't loaded, as `start = $1c52` defines, without the warning. Where two runs label the same address differently (overlays at the same address), the run's own label or none wins; that needs deciding.

Related: [0133](0133-code-that-runs-at-another-address.md) removes the most common reason for a second run.
