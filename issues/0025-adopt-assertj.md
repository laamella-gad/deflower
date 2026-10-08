---
title: Adopt AssertJ to clean up ugly asserts
status: open
labels: cleanup, test
---

`DeflowerTest.java`'s assertions are `assertTrue(x.contains(y) && x.contains(z), "message " + x)` style — manual boolean-combining and manual message-building (e.g. `assertTrue(err.contains("byte") && err.contains("word"), "Expected both area kinds named, got: " + err)`). AssertJ's fluent assertions (`assertThat(err).contains("byte", "word")`) read better and build their own failure message from the actual value automatically.

Done when: `org.assertj:assertj-core` is a test-scoped Maven dependency, and `DeflowerTest`'s `assertTrue`/`assertFalse` calls are converted to `assertThat(...)` equivalents.
