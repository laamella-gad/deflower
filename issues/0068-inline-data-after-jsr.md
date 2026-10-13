---
title: Support routines that read inline data after their JSR
status: done
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

## Design

The routine's `code` line gets a parameter list, like a function in a higher-level language. Each parameter is `<type>[<size>] <name>`, the name optional, and they follow the `jsr` in memory in the listed order:

```
$c000 code print (char[10] text, byte colour)
$2c75 code print_inline (char[until $ff] text)
$1234 code set_ptr (addr pointer)
$b5e8 code dispatch (addr[10] handlers) noreturn
```

- **Sizes.** A fixed size as today, or `until $xx` for data terminated by a value: the area runs up to and including the first `$xx`, so its length comes from memory at each call site.
- **`until` on data lines too.** The same size works on an ordinary `.flo` data line, e.g. `$30dd char[until $ff] water_text`, so a terminated string no longer needs its length counted by hand.
- **`noreturn`.** The data after each call is registered, but the trace doesn't continue after it (e.g. `lB5E8`, a dispatch whose call is followed by an `.addr` table).
- **Where.** A parameter list is only allowed on a `code` line.
- **Call-site override.** A `.flo` data line at a call site wins over the parameter list for that call, and the trace resumes after that area.
- **Output.** `until $00` prints as `.null` (issue 0047), any other terminator as `.text "IN THE WATER", $ff`. Each call site gets the parameter names as a comment. Call sites get no labels.
- **3dgolf_snap.** Its `.flo` keeps the per-site names as plain label lines, and drops the `char[]` lines and the `code` lines that restart the trace.

Later, not in this issue: register and zero-page parameters ([0092](0092-register-parameters.md)), length-prefixed and bit-7-terminated data ([0093](0093-more-terminated-data-shapes.md)). A routine whose data length can't be described this way (e.g. self-modifying) stays a per-call-site job.

Done when: `3dgolf_snap`'s `.flo` declares `l2C75` once, every call site prints its text as data followed by the code after it, the fake labels and `brk`s are gone, `until` works on a plain data line, and short snippets cover a fixed-size parameter, a terminated one, `noreturn` and a call-site override.

## Closing note

Implemented as designed. The grammar has `parameters`, `noReturn` and an `untilSize` alternative inside `[...]`; `FloReader` builds `Parameter`s, and `Subject.annotate` stores a `Routine` per code line that has a list or `noreturn` (an included line doesn't replace one from the including file). `Subject.countUntil` sizes an `until` area, on a data line (an error when memory the image doesn't load comes first) and at a call site. `FlowAnalyser.registerInlineData` registers the parameters after each `jsr`, unnamed, so references into them don't print an undefined label, and returns where the call returns; when the data would run out of the image, into an area or past its terminator, it warns at the `jsr` and stops the trace there. A non-placeholder data line already at the call site is an override: the trace resumes after the data run there.

Two additions:
- **Cross-references.** `Subject.callsByReturnAddress` lets `CrossReferences` look back from the code after the data to the `jsr`, so a reference from there is named by its routine (`nmi`, `swing`) instead of by its address.
- **The call comment** is printed at the end of the `jsr` line (`jsr print_inline	; text`), not as a comment line, which would get a blank line between the `jsr` and its data.

`3dgolf_snap.flo` declares `print_inline` once and `$b5e8 code noreturn` (it ends in `jmp start`, and is followed by the `vectors` table). The text names stay as plain label lines. The seven `newline` lines stay `byte[2]` overrides, because as `char` the encoding guess reads `$0d` as a screen-code `M` (issue [0094](0094-explicit-text-encoding.md)). All 35 "jsr returns into data" warnings for these calls (34 to `print_inline`, one to `$b5e8`) are gone, as are the fake labels and `brk`s, and it still verifies with 0 differ and 0 gaps. A side effect of the different trace order is that the `d0103` data label on decruncher code at `$0103` isn't made anymore (`lda $0103, x` in `add_fill_seed`): a data label is only made when the memory is already decoded.

Fixtures: `short/inlinedata` (terminated text, an empty one, two named bytes, an override, `noreturn` with an `.addr` table), `short/untilsize`, `short/untilmissing`, and `invalid/parameters-on-data`, `invalid/parameter-code`, `invalid/until-too-big`.
