---
title: Write the Nim mpu6502's source parser as an npeg grammar
status: open
priority: low
labels: cleanup
---

`nim/mpu6502/src/mpu6502/source_parser.nim` is a hand-written recursive-descent parser, a straight port of the Java `SourceParser` ([0059](0059-convert-to-nim.md), step 1). Deflower's own `.flo` parser is going to be an [npeg](https://github.com/zevv/npeg) grammar (0059's Decisions). Writing the assembler's syntax as an npeg grammar too would give one way of parsing in the project, and a grammar that can be read as a description of the syntax, which the doc comment at the top of `source_parser.nim` now gives in words.

What has to stay the same:
- **The error messages, word for word.** Deflower prints them (`Verifier`) and the snippets' round trip depends on them. Most quote the rest of the line: `expected a value at '+'`, `unexpected '2'`, `expected a name at '1abc'`. npeg's `E"..."` atoms and `matchMax` give a position, so the messages have to be built from that, or raised from code blocks. The tests in `nim/mpu6502/tests/test_source_parser.nim` check most of them; add any that are missing before the change.
- **What gets parsed.** The rules that aren't plain grammar have to come along: a name at the start of a line is a label unless it is a mnemonic, `asl a` versus an operand named `a`, `@w` only before white space, `'c'` literals and `;` inside strings, the zero page or absolute choice, the `.enc` state, and Java's idea of white space, letters and digits on Unicode characters.
- **The lazy values.** The parser builds `Value` closures that look symbols up later, so forward references keep working. Only the parsing changes, not `assembler.nim`.

npeg becomes a dependency of the mpu6502 package (`requires "npeg"` in `mpu6502.nimble`). It works at compile time, so the executable gains no run-time dependency.

Check first whether it pays off: the parser is line-based and small (about 570 lines), and the messages may need as much code around the grammar as the hand-written version has now. If it doesn't get shorter or clearer, close this as rejected.

Done when `source_parser.nim` is an npeg grammar, `nimble test` in `nim/mpu6502/` passes unchanged, and the Java and Nim versions still assemble the snippets' sources and outputs to the same segments or messages (the cross-check from 0059 step 1).
