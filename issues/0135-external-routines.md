---
title: Name routines that exist only at run time (not in the image, not ROM)
status: rejected
labels: enhancement
---

Some routines are in neither the image nor a ROM: RAM code a KERNAL or a loader installs before the program runs. A `jsr` to them warns `goes into memory the image doesn't load`, and the only way to name them is `banked`, which says the memory is banked in over the program's RAM.

Found in The Write Stuff 128 (`~/dev/c64-productivity/tws128`): the C128 KERNAL copies its far-memory routines into RAM. The program copies them from `$03a2` to `$0232` and patches them (`$2546`) into `sta ($fd),y`, `lda ($fd),y`, `sta ($fb),y` and `lda ($fb),y` for bank 1, called 40-odd times as `jsr $0232`, `$023e`, `$0247`, `$0250`. The program's own documentation names them; the `.flo` file can only say `$0250 banked lda_bank1_fb`.

Want: a keyword for it, e.g. `$0250 extern lda_bank1_fb`. It labels jumps and calls like `banked`, stops the trace and the warning, and the output names it as a define. It may also be what an include uses for the C128's `$02a2` routines. Could be no more than renaming or aliasing `banked`, as the behaviour is the same; the point is a line that says what is meant.

## Closing note

Rejected: `banked` already does this (labels the calls, stops the trace and the warning, prints a define), and a second keyword for the same behaviour adds nothing. `README.md` now says `banked` also names routines that only exist at run time.
