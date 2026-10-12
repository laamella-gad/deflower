---
title: Emit `.null`/`.ptext` for null-terminated and length-prefixed strings
status: done
labels: enhancement
---

Split off from issue 0039. CHAR data now prints as `.text`, one value per `print(DataArea)` call (`AssemblyFileFormat.textPrint`). The two common C64 string conventions come out as plain hex items:

```
nulled:
		.text	"BYE", $00
counted:
		.text	$03, "ABC"
```

64tass has dedicated directives for both: `.null "BYE"` appends the terminator, and `.ptext "ABC"` prepends the length.

The difficulty is that the directive has to be chosen before the string's first item is printed, while a per-value printer only sees one value at a time:
- `.null` needs to know that the string ends in its only `$00`;
- `.ptext` needs to know that the first byte equals the length of the rest.

Options:
- **Peek when a string opens.** When `textPrint` opens a new string (not a continuation), a small lookahead helper, like `isSingleValueRun`, checks the string's shape and picks the directive. The values then still stream one by one, with the length byte and the terminator printing as nothing.
- **Make it explicit in the `.flo` file.** For example, add `null`/`ptext` type keywords (or a modifier on `char`) so the author states the convention, and nothing has to be detected.
- **Buffer the current line** and choose its directive when the line is closed. This only covers strings that fit on one line.

Done when: the `strings` fixture's `nulled` and `counted` print as `.null "BYE"` and `.ptext "ABC"`, and wrapped long strings still assemble to the same bytes.

## Decisions

- **Detect, no `.flo` syntax.** When a char array opens, look at its shape and pick `.null` (ends in its only `$00`) or `.ptext` (first byte is the length of the rest). A wrong guess still assembles to the same bytes, because the directive only adds back the byte it left out, so detection is safe. This matches the existing encoding guess (`likelyTextEncoding`).
- **Long strings:** a null-terminated string longer than a line wraps as `.text` lines, with `.null` on the last one, since it only appends the $00. `.ptext` has to hold the whole string, so it is only used when the string fits on one line; otherwise it stays `.text`.

## Closing note

`AssemblyFileFormat.textDirectiveFor` picks the directive whenever a line of a char array opens: `.null` when the array's only $00 is its last byte and the rest of it fits on the line, `.ptext` at the array's start when its first byte is the length of the rest and that fits on one line, else `.text`. A comment inside the rest of the array breaks the line, so it rules both out. The terminator and the length byte then print as nothing. When both shapes fit, `.null` wins. Fixture `strings` now prints `.null "BYE"`, `.ptext "ABC"`, and `long_nulled` wraps with `.null` on its last line; it reassembles to the `.prg`. No other fixture changed.
