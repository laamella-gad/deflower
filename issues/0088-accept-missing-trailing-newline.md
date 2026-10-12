---
title: Accept a .flo file whose last line has no newline
status: open
priority: low
labels: enhancement
---

The grammar's top rule is `prog: (statement NEWLINE)* EOF;`, so every line needs a newline after it, the last one included. A file that ends without one fails with "Failed to parse". Many editors don't add a final newline, and the error doesn't say what is wrong.

How this came about: [0021](0021-parse-errors-not-collected.md) made parse errors fatal. That exposed the missing newline at the end of `zwark.flo`, which ANTLR's error recovery had papered over until then. The fix added the newline to the file and a test, `rejectsMissingTrailingNewline`, that kept the failure as it was. [0062](0062-snippet-test-factories.md) removed the test, so this behaviour is no longer tested.

Want: a last line without a newline parses like any other, e.g. with `prog: (statement NEWLINE)* statement? EOF;` or by putting `NEWLINE?` before `EOF`.

Done when: a file whose last line, an annotation or a comment, has no trailing newline parses and gives the same output as with one. A short snippet can't hold such a file, since every snippet part ends in a newline, so this needs a plain `@Test` or a `FloReader` unit test.
