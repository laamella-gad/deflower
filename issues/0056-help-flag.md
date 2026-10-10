---
title: Support a --help flag
status: open
priority: low
labels: enhancement
---

`Deflower.main` takes `args[0]` as the `.flo` path without looking at it. Without arguments it fails with an `ArrayIndexOutOfBoundsException`, and `--help` is treated as a `.flo` file name.

Want: `--help` (and `-h`) prints a short usage text and exits: what the argument is (a `.flo` file), where the output goes (`out/<binary>.asm` next to it), and a pointer to the `.flo` format description. Running without arguments prints the same usage, with a non-zero exit code.

Related: [0059](0059-convert-to-nim.md) (which supersedes [0019](0019-ship-as-single-executable.md)) makes the tool runnable from the command line, where this matters most. Note that `main` currently resolves the path on the classpath, not the file system.

Done when: `--help`/`-h` print usage and exit 0, no arguments prints usage and exits non-zero, and a test covers both.

## Decisions

- **Blocked by [0059](0059-convert-to-nim.md).** The command line is rewritten in Nim, together with `--watch` ([0057](0057-watch-mode.md)) and `--verbose` (0059), so do this after the port.
