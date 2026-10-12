---
title: Print cross-references above labels
status: done
labels: enhancement
---

Naming a routine or a variable starts with finding where it is used: which code calls it, jumps to it, reads it or writes it. Deflower knows this while it decodes, but doesn't print it, so every name in `squirm`, `tcmine` and `zwark` was found by grepping the output for the label and reading each place.

Want: a comment above each label listing its references, by kind, with the routine they're in:

```
; called by: game_loop, var_2_stuff
; jumped to by: l336F
move_snake_0:
```

```
; read by: move_snake_0, move_snake_1
; written by: initialize_pointers
snake_0_head:
```

## To decide

- **Kinds.** Call (`jsr`), jump (`jmp`, branches), read, write, read-modify-write (`inc`, `asl`, ...), indexed and indirect access, pointer setup (once [0074](0074-detect-address-setup-pattern.md) exists).
- **Naming the referrer.** The nearest label before the instruction, the nearest `code` entry from the `.flo` file, or the address.
- **References into arrays.** `lda title + $ff, x` refers to `title`. List it there, with or without the offset.
- **Noise.** Local branch targets inside a routine get many short comments. Skip branches, skip references from inside the same routine, or cap the list.
- **On or off.** Always, or behind a flag. Always changes every `expected.asm`.

Done when: a small fixture shows each kind of reference in its `expected.asm`, the other fixtures' changed expectations are reviewed with snipsert, and the output still assembles with 64tass.

## Decisions

- **Kinds.** Five: `called by` (`jsr`), `jumped to by` (`jmp`, branches), `read by`, `written by` (`sta`, `stx`, `sty` and the illegal stores), `modified by` (`inc`, `dec`, `asl`, `lsr`, `rol`, `ror` on memory and the illegal read-modify-writes). Indexed and indirect access fold into these, no kinds of their own. Pointer setup waits for [0074](0074-detect-address-setup-pattern.md).
- **Naming the referrer.** The nearest label at or before the instruction; `$XXXX` when there is none.
- **References into arrays.** Listed at the label the operand prints, so `lda title + $ff, x` is listed above `title`, without the offset.
- **Noise.** Each referrer once per kind. A reference whose referrer is the label itself (a loop back to its own label) is skipped. Branches stay; no cap.
- **On or off.** Always on.
- **Sources.** Instructions only, including the pointer a `jmp (indirect)` reads. `.addr` tables don't count.

## Closing note

`CrossReferences` walks the decoded instructions once before writing and files each operand under the address of the label it prints as (`Area.labelAddressFor`). `AssemblyFileFormat.printCommentLines` prints those lines after the label's own comment, wherever a label is printed: above code and data, in `.virtual` blocks and on address defines. Fixture `xref` shows every kind, a reference into an array, an indirect pointer, a self-loop left out, an uncovered label (`border = $d020`) and a referrer without a label (`$c032`); its output reassembles to the `.prg`. Every other changed expectation adds only cross-reference lines.

Seen in the real programs: the nearest label is often a branch target (`l3395`) rather than the routine's name, and a busy variable's `written by:` line runs to 400 characters.
