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

Done when: a small fixture with a jump into the middle of an instruction and a jump into data prints both warnings, and a fixture without them prints none.
