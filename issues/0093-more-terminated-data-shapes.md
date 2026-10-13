---
title: Bit-7-terminated data, inline and in .flo lines
status: open
priority: low
labels: enhancement
---

[0068](0068-inline-data-after-jsr.md) supports inline data after a `jsr` with a fixed size, or terminated by a value (`char[until $ff] text`). Two other common shapes of variable-length data aren't covered:

- **Length-prefixed**: done in [0094](0094-explicit-text-encoding.md) as the `[lengthbyte]` size, printed as `.ptext`. A length word was left out.
- **Bit-7-terminated**: the last character has bit 7 set, e.g. `"HELL", 'O' | $80`. It is common in BASIC's keyword table and in many games' text. 64tass prints it as `.shift "HELLO"`.

Both need the same thing from the parameter list as `until $ff`: the length comes from the data at each call site, not from the declaration.

Want: both shapes as sizes, in a parameter list and on ordinary `.flo` data lines, e.g.

```
$3000 code show (char[until bit7] text)
$b0b0 char[until bit7] keyword_end
```

## To decide

- **Syntax.** `[until bit7]`, or other words.
- **Arrays of strings.** 0068 lets `until` size a single area on an ordinary data line. An array of terminated strings (a keyword table) needs a count of elements, e.g. `char[until bit7 * 76]`.
- **Output.** `.shift`, and what to print when the data doesn't fit the form, e.g. a byte with bit 7 set inside a `.shift` string, or a non-printable character.
- **Screen codes.** Combined with `screencode` ([0094](0094-explicit-text-encoding.md)).

Done when: a short snippet has a call with bit-7-terminated inline text, printed as `.shift` and passing the round trip.
