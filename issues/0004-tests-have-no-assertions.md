---
title: Tests only smoke-run the pipeline
status: done
labels: test
---

`src/test/java/com/laamella/deflower/DeflowerTest.java` called `new Deflower().deflower(...)` for three fixtures and asserted nothing. A regression in the generated output would have passed unnoticed.

Fix: added `com.laamella:snippets-test-junit5-core:1.0` (test scope) and used `Snipsertions.snipsert` to compare each fixture's generated `deflowered.asm` against a versioned expectation at `src/test/resources/<fixture>/expected.asm`. `Deflower.deflower` now returns the `Subject` so the test can find `subject.outputPath`.

The three expectation files were generated from the current (reviewed) output and committed. A future regression changes one of these files, which `git diff` will show; to accept a change, delete the file and rerun the test, or rerun with `-DREGENERATE_EXPECTATIONS` and review the diff before committing.