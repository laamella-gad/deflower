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

Every value is a closure that looks its symbols up when it is asked for (`Assembler.symbol`), and a define's address is its value, so `b` asks `b` again. Java throws a `StackOverflowError`, an `Error` that the code catching `RuntimeException` doesn't catch. The Nim port does the same, and a debug build stops with "call depth limit reached". Found while porting mpu6502 to Nim ([0059](0059-convert-to-nim.md), step 1). 64tass reports such a loop as an error.

Deflower never writes a define like that: all its defines are numbers, `label = $XXXX` (banked names, labels on uncovered memory, labels inside an array or instruction). So this only matters for hand-written source, or for a future output that defines names in terms of each other.

Fix: track the defines being evaluated, and on a cycle give `line N: b is defined in terms of itself` (a `SourceException` in Java, a `SourceError` in Nim). Fix it in both versions, the Java mpu6502 (`~/IdeaProjects/Mpu6502`) and the Nim one in `mpu6502/`, with the same message, so they stay the same. Deflower itself uses the Nim one only, since [0059](0059-convert-to-nim.md).

Done when assembling a self-referential define gives that error instead of running out of stack in both versions, with a test in Java's `SourceParserTest` and in `mpu6502/tests/test_source_parser.nim`.
