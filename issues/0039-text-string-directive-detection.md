---
title: Detect runs of printable characters and emit 64tass's `.text`/`.null`/`.ptext`
status: open
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
