---
title: Annotate the BIT skip trick without a warning
status: done
labels: enhancement
---

The `bit` skip trick hides an instruction in the operand of a `bit abs` (`$2c`) or `bit zp` (`$24`): code that
falls into the `$2c` skips the next two bytes, code that jumps one byte further runs them.

```
$255c  a9 49     lda #$49        ; set_error_73
$255e  2c        .byte $2c       ; bit $00a9 when falling through
$255f  a9 00     lda #$00        ; clear_error (jsr target)
```

Found in RAMDOS 4.3 and d128.ml, disassembled in `~/dev/c64-productivity/tws128/tools/tools.flo`: 16 such spots.
Neither way of annotating them runs clean:
- `$255e byte bit_skip_255e`, the hidden instruction as code: one `falls through into data at $255e` warning per
  spot. This is the current choice; the tools project keeps 17 warnings because of it (the 17th is a `beq` that is
  always taken, falling "through" into a table).
- `$255e code bit_skip_255e`: `code entry is inside the instruction at $255e`, plus one `goes into the middle of the
  instruction` per caller of the hidden instruction (6 warnings for this one spot).

Want: a way to say "this byte is a `bit` that skips the next instruction", e.g. `$255e bitskip` (or a `skip` type).
- The byte prints as `.byte $2c ; bit $00a9 (skips clear_error)`.
- Falling into it continues the trace two (or one, for `$24`) bytes further, so the trace doesn't stop and doesn't warn.
- The hidden instruction stays an ordinary code entry.

Related: [0089](0089-silence-accepted-warnings.md) (accepting warnings) would also cover it, but the trick is common
enough in 6502 code to deserve its own line. The skill notes already say "give both entries a code line", which
Deflower can't do without warnings today.

## Done

Without a new keyword: `flow_analyser.nim` recognises the trick from the data line itself. A fall-through from an
instruction into a one-byte data line holding `$2c` or `$24` doesn't warn, and the trace goes on 3 (or 2) bytes
further. The 17th warning of the tools project, `lda #$00 / beq` falling "through" into a table, is handled too: a
branch whose flag the instruction right before it sets (`lda`/`ldx`/`ldy #` before `beq`/`bne`/`bmi`/`bpl`,
`clc`/`sec`/`clv` before a carry or overflow branch) isn't followed the way it can't go when that is declared data.
Dead code that isn't declared data is still traced, so existing disassemblies don't change; zwark loses one warning
(`clc / bcc main_loop` before `player_state`). Tracking the flags across more instructions was tried and dropped as
too much code for what it catches. Snippet `tests/snippets/short/bitskip.txt`; README "The output" describes both. The tools
project of The Write Stuff 128 now runs without warnings.
