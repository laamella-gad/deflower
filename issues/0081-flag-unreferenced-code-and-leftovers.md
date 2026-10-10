---
title: Point out code nothing reaches and likely leftover memory
status: open
priority: low
labels: enhancement
---

Programs taken from snapshots carry leftovers: code that was patched over, old copies of routines, the remains of the assembler or loader, and zero-filled space. In `squirm` these were found by reading every gap by hand:
- `$32d5`, the original of `test_cell`, with its first instruction overwritten by a `jmp`;
- `$3d18`, code that falls into `countdown_irq` but that nothing calls;
- `$080e-$0fa0` and `$2af0-$2ff9`, a BASIC program and tables of the assembler the game was written with;
- `$2572-$2648`, `$26dd-$2800`, mostly zeros.

Want: Deflower points these out, e.g. as warnings ([0077](0077-analysis-warnings-report.md)) or comments in the output:
- a gap that decodes as a sequence of valid instructions ending in `rts`/`jmp`, as possible unreached code;
- a run of more than a few identical bytes, as likely padding;
- a gap that looks like BASIC tokens or text.

## To decide

- **How sure.** These are guesses. They should only ever be suggestions, never areas, so they don't change the output unless the user declares them.
- **Thresholds.** Minimum length for a decodable run or a padding run.

Done when: `squirm` with its original `.flo` file gets a suggestion for each range listed above, and a fixture with only real data gets none.
