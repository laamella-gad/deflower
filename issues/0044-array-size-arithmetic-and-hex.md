---
title: Allow hex values and `*`/`+` arithmetic inside `[n]` array sizes
status: open
labels: enhancement
---

In `Flo.g4`, the array size is declared as `datatype: (CHAR|BYTE|WORD|DWORD|CODE) ( '[' arraySize=INT? ']')?`, so only a
plain decimal integer is allowed between the brackets:

- `byte[$20]` is a parse error, even though hex (`$`) is accepted everywhere else a number appears (addresses, ranges,
  `n*m`).
- `byte[40*21]` and `byte[8+2]` are parse errors. Today a computed size has to be written with the separate `n*m`
  multiplier expression (`$16d2 40*21 byte level_1`, as `squirm.flo` does after issue 0032), which reads less naturally
  than putting the size next to the type. `+` has no equivalent at all.

Related gap: the grammar already has a top-level `number '+' number # plus` alternative, but `SubjectConfigurer` has no
`enterPlus`/`exitPlus` handler. A line like `$c000 3+4 byte` parses without error and the `+` is silently ignored.

## Decisions (from the user)

- **The top-level `n*m` multiplier form is removed.** A size is given in exactly one of two ways: `[...]` after the
  type, or a `start-end` address range. Remove the `mul` alternative from the `expr` rule, along with
  `SubjectConfigurer.enterMul`. Remove the orphan top-level `plus` alternative too, since top-level arithmetic goes away
  entirely and all arithmetic lives inside `[ ]`.
- **A size that evaluates to 0 is an error,** not a silent no-op. That covers both a `[...]` expression that evaluates
  to 0 and a range too short to fit a single element of the type. An example of the second is `$c006-$c007 word`: the
  end is exclusive, so that is one byte, 0 words. That trap was hit while writing the `partialarraycarve` fixture.
  Report the error through `Subject.errors`, or fail like a parse error, so it can't pass unnoticed.

## Implementation

Replace `arraySize=INT?` with a small arithmetic expression over `number` (so `INT|HEX`), supporting `*` and `+` with
normal precedence (`*` binds tighter), and parentheses if cheap. Evaluate it in `enterDatatype` (or `exitDatatype`)
into `amount`, reusing `parseNumber` for the leaves. Examples that should work:

```
$2800 byte[8*64] charset
$1041 byte[$af] high_score_screen
$138a byte[40*19+5] title
```

Fixtures that use the removed top-level form must be converted. Currently that is `squirm.flo`:
`$16d2 40*21 byte level_1` becomes `$16d2 byte[40*21] level_1`, and likewise for `level_2`, `level_3`,
`title_screen_colors`, and `$2800 8*64 byte charset`. Their output must stay unchanged.

Done when:

- hex, `*` and `+` all work inside `[ ]` and match the plain `[n]` equivalent;
- the top-level `mul`/`plus` grammar rules and their handling are gone;
- a size of 0 (from `[...]` or from a range) is reported as an error;
- a fixture or test covers each form and the zero-size error;
- all existing fixtures pass, with `squirm.flo` converted and its `expected.asm` unchanged.
