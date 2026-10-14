---
title: mpu6502's assembler recurses forever on a define that refers to itself
status: open
priority: low
labels: bug
---

A define whose value depends on itself, directly or through other defines, makes mpu6502's assembler recurse until the stack runs out:

```
*=$c000
        .byte b
b = b
```

Every value is a closure that looks its symbols up when it is asked for (`Assembler.symbol`), and a define's address is its value, so `b` asks `b` again. Java throws a `StackOverflowError`. That is an `Error`, not a `RuntimeException`, so `Verifier` and `DeflowerTest`, which catch `RuntimeException`, don't catch it. The Nim port does the same, and a debug build stops with "call depth limit reached". Found while porting mpu6502 to Nim ([0059](0059-convert-to-nim.md), step 1). 64tass reports such a loop as an error.

Deflower never writes a define like that: all its defines are numbers, `label = $XXXX` (banked names, labels on uncovered memory, labels inside an array or instruction). So this only matters for hand-written source, or for a future output that defines names in terms of each other.

Fix: track the defines being evaluated, and on a cycle give `line N: b is defined in terms of itself` (a `SourceException` in Java, a `SourceError` in Nim). Fix it in both versions, the Java mpu6502 (`~/IdeaProjects/Mpu6502`) and the Nim one in `nim/mpu6502/`, with the same message, so they stay the same. As in [0122](0122-accumulator-mode-disagrees-between-opcode-tables.md), this changes mpu6502 only, not deflower's output, so it doesn't fall under the feature freeze of [0059](0059-convert-to-nim.md). Deflower picks up the Java change through the `0.2-SNAPSHOT` in `~/.m2` after an `mvn install` in the mpu6502 project.

Done when assembling a self-referential define gives that error instead of running out of stack in both versions, with a test in Java's `SourceParserTest` and in `nim/mpu6502/tests/test_source_parser.nim`.
