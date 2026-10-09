---
title: Emit `.null`/`.ptext` for null-terminated and length-prefixed strings
status: open
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
