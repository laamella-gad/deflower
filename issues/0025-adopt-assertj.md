---
title: Adopt AssertJ to clean up ugly asserts
status: done
labels: cleanup, test
---

`DeflowerTest.java`'s assertions are `assertTrue(x.contains(y) && x.contains(z), "message " + x)` style — manual boolean-combining and manual message-building (e.g. `assertTrue(err.contains("byte") && err.contains("word"), "Expected both area kinds named, got: " + err)`). AssertJ's fluent assertions (`assertThat(err).contains("byte", "word")`) read better and build their own failure message from the actual value automatically.

Done when: `org.assertj:assertj-core` is a test-scoped Maven dependency, and `DeflowerTest`'s `assertTrue`/`assertFalse` calls are converted to `assertThat(...)` equivalents. ✅

Fixed: added `org.assertj:assertj-core:3.27.7` (test scope, already in the local `~/.m2`, so the offline build resolves it). Every `assertTrue`/`assertFalse` in `DeflowerTest` is now `assertThat(...)`; the `&&`-combined `contains` checks became AssertJ's varargs `.contains(a, b)`, and the two `isEmpty(outDir(...))`-plus-manual-message calls became `.as("...").isTrue()`. `PrintingTest` converted too: `assertEquals` → `assertThat(...).isEqualTo(...)`, `assertThrows` → `assertThatThrownBy(...).isInstanceOf(...)`. No other test class used JUnit's `Assertions`.
