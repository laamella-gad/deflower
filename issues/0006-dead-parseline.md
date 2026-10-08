---
title: Unused legacy parseLine in SubjectConfigurer
status: open
labels: cleanup
---

`SubjectConfigurer.parseLine` (`src/main/java/com/laamella/deflower/SubjectConfigurer.java`) is never called. The grammar-based listener in `configure` replaced it. Keeping it means two parsers for the same syntax that can drift apart.

Done when: all `parseLine` functionality is available in the listener, and anything only it uses are deleted, and the tests still pass.
