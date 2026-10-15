---
title: Preview an untraced range as code without declaring it
status: open
priority: medium
labels: enhancement
---

Deflower only decodes instructions the trace reaches from a `code` entry point. Memory the trace doesn't reach is printed as data, even when it is code. To find out whether a gap holds code, the user has to add a `code` line, rerun, read the output, and remove the line again if the gap turned out to be data. A wrong guess isn't harmless while it's in place: it registers instruction areas, auto-labels its branch targets, and can trace on into real data or cause area conflicts.

Seen while disassembling fixture `3dgolf_snap`. Its gaps hold a mix of things:
- `$2c8b-$2cca`: unreferenced code, routines that print or store a byte as two hex digits.
- `$2cd3`: an unreferenced second start-up entry (`jmp $a003`).
- `$0878-$08da`: the original tape version's loader, which is dead code.
- `$a00c-$a02b`: a table of addresses that only *looks* like code at first (`sbc $ab, x`, `lsr $48ac`, ...).
- `$a02b-$a09d`: ASCII digits.

Telling these apart meant disassembling each gap by hand, outside Deflower. `3dgolf_snap.flo` declares them all by now, so a test of this needs the file without those lines.

Want: a way to look at a range as code (a linear sweep from its start) that changes nothing else about the run. It must not register areas or labels, follow branches out of the range, or conflict with what is declared there.

To decide:
- **Where it's asked for.** Options:
  - a `.flo` modifier on a range, e.g. `$2c8b-$2cd0 preview`;
  - a run option that previews every gap the trace left;
  - both.
- **Where it shows up.** Options:
  - as comments next to the data in `out/<binary>.asm`, which keeps reassembly intact;
  - in a separate file, e.g. `out/<binary>.preview.asm`;
  - in the log.
- **What it shows.** Options:
  - the plain linear sweep;
  - also marks that help judge it: illegal opcodes, `brk` runs, branches that leave the range or land mid-instruction, and operands that match existing labels.

Related: [0057](0057-watch-mode.md) (the re-run loop this is meant to shorten).

Done when: a range in `3dgolf_snap` can be previewed as code without changing the rest of its output, and the way to ask for it is documented in `README.md` if it involves the `.flo` file.
