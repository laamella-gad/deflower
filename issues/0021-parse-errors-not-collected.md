---
title: Parse errors are printed to stderr and ignored, not collected and failed on
status: done
labels: bug
---

`SubjectConfigurer.configure` builds `FloParser` with no custom error listener, so a malformed `.flo` file (e.g. a typo, a stray token) hits ANTLR's default `ConsoleErrorListener`: it prints `line X:Y mismatched input ...` to stderr and recovers, then the walker continues over whatever (possibly wrong) tree ANTLR managed to build. The pipeline can run to completion and write `deflowered.asm` from a silently-mis-parsed file, with the only trace being an easy-to-miss stderr line among all the other `System.out` tracing (see [0005](0005-debug-output-everywhere.md)).

This came up while fixing [0010](0010-second-deflower-wipes-annotations.md): grammar changes alone can't be relied on to *fail* on bad input, because ANTLR's default strategy doesn't throw.

Done when: the lexer/parser use a custom `ANTLRErrorListener` (or error strategy) that collects every syntax error, and `configure` throws a clear exception listing them (file, line, message) if the collection is non-empty, instead of letting the parse continue.

**Fix:** `SubjectConfigurer.configure` now attaches a shared `BaseErrorListener` to both the lexer and the parser (after `removeErrorListeners()`), collecting `"line %d:%d %s"` for every syntax error. After `parser.prog()` returns, it asserts the collection is empty before walking the tree; otherwise it throws `IllegalStateException` naming the file and listing every collected error.

This immediately caught a real, previously-silent bug: `zwark.flo` had no trailing newline, so the grammar's `(statement NEWLINE)*` couldn't match the last line, which ANTLR's old default behaviour papered over with token-insertion recovery. Fixed the fixture by adding the trailing newline.

The full error list (one `line L:C message` per entry) is embedded in the `IllegalStateException`'s message. `Deflower.deflower` catches `IllegalStateException` around the `configure` call, prints `e.getMessage()` to stderr, and returns without running flow analysis or writing output - so a malformed file stops the pipeline cleanly and the detail is visible in the run output, instead of a stack trace or (per the original bug) nothing at all.

Added two regression tests to `DeflowerTest` (`src/test/resources/invalid/garbage-tokens.flo`, `.../missing-trailing-newline.flo`). Since `deflower()` doesn't propagate the failure, they check its effects instead of catching an exception: stderr contains "Failed to parse", and no `deflowered.asm` was written. Full `mvn -o test` passes (5/5); the three valid fixtures' `expected.asm` files are unchanged.
