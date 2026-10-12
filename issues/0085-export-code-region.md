---
title: Export chunks of code with the export command
status: open
priority: medium
labels: enhancement
---

[0022](0022-export-region-to-binary.md) adds `export <name>.bin` for data lines only: a `code` line with `export` is an error, and an exported region is fixed data, so the tracer stops at it.

Want: mark a chunk of code for export too, e.g. a routine that is copied elsewhere at run time, a music player, or a loader.

Open questions:
- **Output.** As a binary (`.binary "loader.bin"`, the code no longer disassembled in the main file), or as source (`.include "loader.asm"`, which is [0058](0058-disassemble-region-to-separate-asm-file.md))? Possibly both, chosen by the extension as decided for 0022/0058.
- **What the region is.** A `code` line only gives an entry point; the code's extent comes from tracing. So the region needs a range (`$c000-$c400 code loader export loader.bin`), or ends wherever the traced code ends.
- **Tracing.** Should the tracer still decode the exported code, so jumps and calls into it get labels and cross-references, and its own references to the rest of the program still label their targets? For a `.bin` export those labels can only be printed as `label = $xxxx` defines after the `.binary` line.
- **Boundaries.** An instruction straddling the region's edge: error, as decided for 0058.

Done when: a code region can be exported, with a fixture showing the main file still reassembles to the same bytes.
