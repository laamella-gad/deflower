---
title: Collect suspect spots found by the analysis into a warnings list
status: open
priority: medium
labels: enhancement
---

While tracing, Deflower notices things worth the user's attention, but they either scroll past in the tracing output ("Jumping into non-code area") or are not reported at all. Spots that needed finding by hand in `squirm`:
- `jsr $2441` jumps into the middle of an instruction (the end of `draw_high_score_screen` decodes as `sbc $60,x` from there);
- code nothing reaches, like `unused_3d18` and the patched-over `old_test_cell` at `$32d5`;
- ranges no area covers;
- a `.flo` `code` entry inside another instruction.

Want: Deflower collects these as warnings, separate from errors (which stop the output), and prints them at the end of a run as one line each, with the address:

```
warning: $3d0b: jsr into the middle of the instruction at $2440
warning: $2441: no instruction starts here, but reset_everything calls it
```

## To decide

- **Which warnings.** At least: a jump or call into data, into the middle of an instruction, or into memory the image doesn't load; a `code` entry that doesn't start an instruction; an operand that points into an uncovered range.
- **Machine-readable form.** Also write them to a file (e.g. `out/<binary>.warnings` or JSON) so a script or an agent can read them without parsing the log.
- **Silencing.** A way to accept a warning in the `.flo` file once it is understood, e.g. a comment keyword, so a finished disassembly runs clean.
- **Relation to the tracing.** [0059](0059-convert-to-nim.md) moves the tracing behind `--verbose`; the warnings would still print without it.

## Tracing in the snippets

Since [0062](0062-snippet-test-factories.md), each snippet's first expectation is everything a run printed, so the tracing is now test output. Most of it repeats what the snippet already shows. In `large/zwark.txt` the printed part has 260 "Marking area" lines, which repeat the `.flo` file, and 145 "Unnamed target" lines, which repeat the labels in the `.asm`. There are also 48 "Will disassemble" lines, plus "Reading prg", "load address" (in decimal) and the VICE header dump. The large snippets total about 34,000 lines, and `3dgolf_snap.txt` alone is 16,668. Adding one label to a `.flo` file changes several printed lines as well as the `.asm`, so diffs get noisy, and the few useful lines are hard to find, for a person or an agent reading the snippet.

Want: a normal run prints only warnings, errors and the files it writes. The rest of the tracing goes, or moves behind a `--verbose` flag that the snippet tests don't use. The warnings this issue collects then make up most of each snippet's printed output.

- **To decide:** drop the tracing, or keep it behind `--verbose` ([0056](0056-help-flag.md)) as [0059](0059-convert-to-nim.md) plans for the Nim port.

Done when: a small fixture with a jump into the middle of an instruction and a jump into data prints both warnings, and a fixture without them prints none, and without `--verbose` the snippets' printed output holds only warnings, errors and the "Writing" lines.
