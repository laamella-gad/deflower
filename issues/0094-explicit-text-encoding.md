---
title: Declare a char area's text encoding and string shape in the .flo file
status: done
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

## Closing note

Decided and done:
- **Syntax.** Two new types, `screencode` (64tass `"screen"`) and `ascii` (Commodore ASCII, 64tass `"none"`). "PETSCII" isn't a Commodore name, and "screen" alone is too generic.
- **No more guessing.** The `char` type is gone, without a compatibility error: `char` is now an ordinary name. With it went the encoding guess (issue 0040, `Subject.likelyTextEncoding`) and the `.null`/`.ptext` shape guess (issue 0047), and `short/screencodes.txt`, which only showed the guess. It also ends the mix-up with 64tass's `.char`, which is a signed byte.
- **Encodings.** Only these two; case sets and plain ASCII can come later.
- **Shape.** Text prints as `.text`, as `.null` only when sized `[until $00]` (`DataArea.terminator`), and as `.ptext` only when sized by the new `[lengthbyte]` (`DataArea.lengthByte`), so every combination of encoding and shape can be declared. The length byte counts the elements after it, as in 64tass, and works for any one-byte type, on data lines and in parameter lists. A `.ptext` is one line however long, since it can't be split. A `.null` or `.ptext` array opens its own line even without a label, so the next array isn't taken into its string. A length word was considered and left out: 64tass has no directive for it.
- Bytes with no character in the encoding print as hex items, as before.

`short/textencoding.txt` shows screen-code "hello" and a `$0d, $ff` newline, which the guess read as ASCII "HELLO" and screen code "M", every encoding and shape combination, the length-byte strings (empty, 40 characters long, unlabelled, and inline as a `screencode[lengthbyte]` parameter), and an inline `screencode[until $ff]` parameter. `short/invalid/lengthbyte-word.txt` shows that a length byte needs a one-byte type. 64tass reassembles `textencoding` and `strings` to the source bytes.

The real programs' `char` lines became `ascii` or `screencode`, whichever the guess picked, so their `.asm` output is unchanged. Some may be worth a second look, e.g. zwark's `turns_text` and `top_score_line` are `ascii` next to `screencode` texts. 3dgolf: `print_inline` now takes `ascii[until $ff]`, so the seven `newlineN` `byte[2]` overrides became plain labels, printed as `.text $0d, $ff`.
