---
title: Detect runs of printable characters and emit 64tass's `.text`/`.null`/`.ptext`
status: done
labels: enhancement
---

Split out of issue 0036. 64tass (https://tass64.sourceforge.net/, "Storing numeric values"/text section) has dedicated string directives:

- `.text` - assembles character strings into 8-bit bytes using the current encoding.
- `.null` - identical to `.text`, but appends a zero terminator byte.
- `.ptext` - prepends a byte count before the string data, Pascal-style (max 255 bytes).

Deflower's `DataType.CHAR` today only prints one quoted char literal per byte (`AssemblyFileFormat.asChar(...)`, under `.BYTE` - see issue 0036 for the directive-name question on this type generally). A recognized run of printable characters - especially one that's null-terminated or length-prefixed, both very common C64-era string conventions - could print far more readably as a single `.text`/`.null`/`.ptext` line instead of N separate single-character `.BYTE 'x'` lines.

This is bigger scope than a directive rename (issue 0036) or a new numeric type (issue 0037): it needs actual *detection* -

- Recognize a contiguous run of `CHAR`-typed bytes as a candidate string (already have per-byte `CHAR` areas; need to decide how a run becomes "one string" for printing purposes - same question issue 0028 already raised for mid-block labels fragmenting a run).
- Recognize the two common terminator conventions: a trailing `$00` (→ `.null`, byte excluded from the visible string) and a leading length byte (→ `.ptext`, byte excluded, consumed as the count instead). Plain `.text` for a run with neither.
- Decide how a `.flo` author opts into this - a new type keyword (`text`?), or automatic detection whenever a `char[n]` array happens to look like a string (riskier - could misfire on genuinely non-string character data).

Done when: a `.flo`-declared character array prints as one `.text`/`.null`/`.ptext` line (whichever fits) instead of per-byte `.BYTE`/`.char` lines, with fixtures covering a plain string, a null-terminated one, and a length-prefixed one.

## Closing note

Done for `.text`. `.null`/`.ptext` are split off into issue 0047.

Decisions taken:
- **Opt-in through the existing `char` type,** with no auto-detection on `byte` data and no new keyword. A `char` declaration already says "this is text", so it doesn't misfire on non-string data.
- **One value per call, like every other type.** `print(DataArea)` prints a single CHAR value via `textPrint`, the string counterpart of `tabularPrint`. It tracks:
  - an open double-quoted literal (`inQuotes`), which `newLine()` closes, and so does `close()` at the end of the file;
  - the column, with a line break every 32 values.

  A label or comment inside a run breaks the line the same way it does for `.byte` dumps.
- **Items:** printable ASCII (`$20`-`$7E`) shares one double-quoted literal. Everything else, including `"` itself, becomes a hex item, e.g. `.text "HI", $0D, $22, "Q", $22`.
- **No `.null`/`.ptext`.** Choosing either needs the whole string before its first item is printed, which a per-value printer doesn't have. A terminator or length byte prints as a hex item instead, e.g. `.text "BYE", $00` and `.text $03, "ABC"`.

Changes:
- `ResultWriter`: `textPrint` replaces the per-byte `asChar` output.
- New fixture `strings` (test `charRunsBecomeTextStrings`). It covers plain, null-terminated, length-prefixed, mixed non-printable and wrapped strings, plus a code operand resolving to `plain`.
- `datatypes/expected.asm`: `.byte 'H', 'i', '!'` became `.text "Hi!"`.

Related: CHAR bytes are still assumed to be ASCII under 64tass's default encoding. Screen codes and PETSCII (issue 0040) print as hex items or wrong letters until that issue lands.

29/29 green.
