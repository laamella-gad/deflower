---
title: Print cross-references above labels
status: open
priority: high
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
