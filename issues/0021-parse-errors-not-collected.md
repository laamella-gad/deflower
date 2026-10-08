---
title: Parse errors are printed to stderr and ignored, not collected and failed on
status: open
labels: bug
---

`SubjectConfigurer.configure` builds `FloParser` with no custom error listener, so a malformed `.flo` file (e.g. a typo, a stray token) hits ANTLR's default `ConsoleErrorListener`: it prints `line X:Y mismatched input ...` to stderr and recovers, then the walker continues over whatever (possibly wrong) tree ANTLR managed to build. The pipeline can run to completion and write `deflowered.asm` from a silently-mis-parsed file, with the only trace being an easy-to-miss stderr line among all the other `System.out` tracing (see [0005](0005-debug-output-everywhere.md)).

This came up while fixing [0010](0010-second-deflower-wipes-annotations.md): grammar changes alone can't be relied on to *fail* on bad input, because ANTLR's default strategy doesn't throw.

Done when: the lexer/parser use a custom `ANTLRErrorListener` (or error strategy) that collects every syntax error, and `configure` throws a clear exception listing them (file, line, message) if the collection is non-empty, instead of letting the parse continue.
