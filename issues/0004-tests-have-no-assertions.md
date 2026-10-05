---
title: Tests only smoke-run the pipeline
status: open
labels: test
---

`src/test/java/com/laamella/deflower/DeflowerTest.java` calls `new Deflower().deflower(...)` for three fixtures and asserts nothing. A regression in the generated output would pass unnoticed.

Done when: each test checks something about `out/deflowered.asm` (for example, expected labels or a known instruction sequence) for at least `zwark` and `tcmine`.
