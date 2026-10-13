---
title: Declare a char area's text encoding and string shape in the .flo file
status: open
priority: medium
labels: enhancement
---

A `char` area prints as `.text`, and two guesses decide how:
- **Encoding.** `Subject.likelyTextEncoding` counts the uppercase letters under each encoding, `$41-$5A` for `"none"` (PETSCII/ASCII) and `$01-$1A` for `"screen"` (screen codes), and picks the larger count for each char array. A tie keeps the previous encoding. `ResultWriter` then switches with `.enc "screen"`/`.enc "none"`.
- **Shape.** [0047](0047-null-and-ptext-string-directives.md)'s `AssemblyFileFormat.textDirectiveFor` picks `.null` when the array's only `$00` is its last byte, and `.ptext` when the first byte equals the length of the rest.

The guesses still assemble to the right bytes, but they often read wrong. Text that is mostly digits, punctuation, spaces or reverse video ties, or tips the wrong way, and then prints as garbage characters. A short array may look like a `.ptext` string by chance. The user knows which it is, but has no way to say so.

Want: the `.flo` line states the encoding, and the shape when it matters. A stated encoding or shape is never guessed.

```
$c100 screen[20] title_text          ; screen codes
$c120 char[20] prompt                ; PETSCII
$30dd char[until $00] bye            ; .null, from 0068's until size
$3100 screen[until $ff] water_text
```

Plain `char` keeps the guesses, so a quickly written `.flo` line still reads reasonably.

## To decide

- **Syntax.** A separate type per encoding (`screen`, alongside `char` for PETSCII), or a modifier (`char[20] screen title`). The grammar has one type slot, so a type is simpler. If `char` itself becomes "PETSCII, no guessing", an untyped way to keep the guess is needed, e.g. `text`. Then the reserved-word list grows.
- **Which encodings.** PETSCII (64tass `"none"`) and screen codes are the C64 ones. Whether to tell PETSCII uppercase/graphics from lowercase/uppercase apart (it changes which letters print as which case), and whether to allow plain ASCII for non-Commodore binaries.
- **Shape from the size.** `until $00` prints as `.null`, and [0093](0093-more-terminated-data-shapes.md)'s `prefixed` as `.ptext`. A plain fixed size with an explicit encoding: does it still guess the shape, or always print `.text`?
- **Data that doesn't fit.** A byte that has no printable character in the stated encoding prints as a hex item, as today. With `until`, no terminator before the area runs into something else is a warning.
- **Parameters.** The same types in [0068](0068-inline-data-after-jsr.md)'s parameter lists, e.g. `(screen[until $ff] text)`.

Done when: a short snippet has a screen-code string that `likelyTextEncoding` gets wrong today and a PETSCII one, both declared explicitly and printed in their encoding, plus a plain `char` one that still guesses; all pass the round trip.
