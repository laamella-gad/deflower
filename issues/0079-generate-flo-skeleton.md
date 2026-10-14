---
title: Write a .flo file skeleton from the analysis
status: open
priority: medium
labels: enhancement
---

Starting a disassembly means writing `.flo` lines for everything the trace found or didn't find. For `squirm`, `tcmine` and `zwark` that meant copying every `lXXXX`/`dXXXX` label and every gap out of the output into `.flo` lines by hand, before the real work, naming them, could start.

Want: Deflower writes the `.flo` lines it would need to reproduce its current analysis, e.g. to `out/<binary>.flo.skeleton`:
- a `code` line for every routine it found (`jsr` targets, entry points), with its automatic label;
- a typed line for every automatically labelled data address;
- a `byte` range for every gap between areas;
- (a `virtual` range for every stretch of untouched memory is done: `--init`, [0072](0072-inspect-input-file.md), writes them, without the trace);
- the lines of the current `.flo` file, so the skeleton is a complete replacement.

The user then renames and narrows instead of discovering.

## To decide

- **Merge or separate.** Write a separate file to copy from, or rewrite the `.flo` file in place, keeping its comments and order.
- **Granularity.** Every branch target, or only `jsr` targets and other routine starts.
- **Relation to `--init`.** `--init` ([0072](0072-inspect-input-file.md)) writes the starting skeleton from the bytes alone; this one depends on the trace. Possibly an option of a normal run, or a second step after `--init`. [0108](0108-gaps-with-context.md) proposes pastable lines per gap in the verify report, which covers the gap part.

Done when: the skeleton for a fixture, used as its `.flo` file, gives the same output as the original apart from the added declarations, and `squirm`'s skeleton has a line for every gap the original `.flo` file left.
