---
title: Support a --help flag
status: open
priority: low
labels: enhancement
---

`Deflower.main` already prints a usage block (one line per mode: a `.flo` file with `--verify`, `--init`, `--dump`, `--find`, `--strings`) and exits with 2 when the arguments don't match. What is left:
- `--help` and `-h` print the same usage, but as an error with exit code 2, since they are read as unknown flags. They should print it to stdout and exit 0.
- The usage says nothing about where the output goes (`out/<binary>.asm` next to the `.flo` file) or where to find the `.flo` format description.
- No test covers the usage.

Want: `--help` prints a short manual, not only the usage lines:
- the modes and their arguments, as now, and where the output goes (`out/<binary>.asm`, `.map`, exported binaries next to the `.flo` file);
- what to write in a `.flo` file: the `deflower` line, annotation lines (`<address or start-end> [virtual] [<type>[<size>]] [<label>] [export <file>] [{]`, exclusive range end), the types, sizes (`[n]`, `[until $xx]`, `[lengthbyte]`), `code` lines with parameter lists and `noreturn`, blocks, `include` and the built-in `c64.flo`, comments, and number syntax;
- a few example lines;
- the suggested loop: `--init`, run with `--verify`, read the `.asm`, annotate, run again.

Short enough to read in a terminal: a reference, not the full description.

## To decide

- **One source for the format.** The full `.flo` description is the comment at the top of `Flo.g4`. A second copy in the manual will drift from it. Options:
  - the manual is a resource file (e.g. `src/main/resources/deflower/manual.txt`) and the grammar comment points to it, or the other way round;
  - the manual is a summary that points to `Flo.g4` for the details;
  - a test checks that every keyword in the grammar appears in the manual.

Related: [0059](0059-convert-to-nim.md) (which supersedes [0019](0019-ship-as-single-executable.md)) would replace the `./deflower` script with a native executable.

Done when: `--help`/`-h` print the manual, including how to write a `.flo` file, and exit 0, no arguments prints usage and exits non-zero, and a test covers both.

## Decisions

- **Blocked by [0059](0059-convert-to-nim.md).** The command line is rewritten in Nim, together with `--watch` ([0057](0057-watch-mode.md)) and `--verbose` (0059), so do this after the port.
