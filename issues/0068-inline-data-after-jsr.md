---
title: Support routines that read inline data after their JSR
status: open
priority: medium
labels: enhancement
---

A common 6502 idiom: a routine pulls its own return address off the stack, reads data that follows the `jsr` in memory, and returns past it. `FlowAnalyser` assumes every `jsr` returns to the next byte, so it traces the data as code.

Seen in fixture `3dgolf_snap`. `l2C75` prints the text after its call:

```
l2C75:  pla / sta $02 / pla / sta $03   ; return address - 1
        inc $02 ...                      ; now points at the text
        jsr l2C60                        ; print until $ff
        lda $03 / pha / lda $02 / pha
        rts                              ; continue after the $ff
```

The text is terminated by `$ff`, and execution continues after the `$ff`. There are about ten call sites, e.g. `$30da` (`IN THE WATER`), `$313b` (`OUT OF BOUNDS`), `$3164` (`SELECT CLUB`), `$2da6` (`SWING CLUB`), `$a18c` (`PLAYER`). Today one of them prints as:

```
		jsr l2C75
		eor #$4e       ; "IN"
		jsr l4854      ; " TH"
		eor $20        ; "E "
		sre $41, x     ; "WA"
		...
```

The fake `jsr`s also make labels and `brk` instructions at `$4854`, `$4f42`, `$4f48` and `$5645`, which aren't code.

Today's workaround: declare the text after each call site in the `.flo` file (e.g. `$30dd char[13] water_text` plus `$30ea code`). That works, but it has to be repeated at every call site, and the trace stops after the text unless a `code` line restarts it.

Want: say once, on the routine, that its calls are followed by inline data, and let the analyser handle every call site: register the data area after each `jsr` to it and carry on tracing after the data.

To decide:
- **Syntax.** A modifier on the routine's `code` line saying what follows, e.g. `$2c75 code print_inline inline char until $ff`. Which shapes to support: terminated by a value (`$ff` here, `$00` in many programs), a fixed size (`byte[2]`, e.g. a pointer argument), maybe a length-prefixed string.
- **Output.** 64tass has `.null` for `$00`-terminated text (issue 0047), but nothing for `$ff`, so this one would print as `.text "IN THE WATER", $ff`.
- **Where the trace continues.** After the data, as `l2C75` does. A routine that never returns (it jumps elsewhere) doesn't fit this and isn't in scope.

Done when: `3dgolf_snap`'s `.flo` declares `l2C75` once, every call site prints its text as data followed by the code after it, the fake labels and `brk`s are gone, and a small fixture covers a call with inline data.
