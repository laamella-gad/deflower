---
title: Snapshot path is resolved twice
status: open
labels: cleanup
---

`SubjectConfigurer.enterSetFileName` (`src/main/java/com/laamella/deflower/SubjectConfigurer.java`, around lines 64-66) resolves the file name against `subject.basePath` twice. The second `resolve` is redundant. Harmless today.

Done when: the path is resolved once.
