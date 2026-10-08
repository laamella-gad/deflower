---
title: Snapshot path is resolved twice
status: done
labels: cleanup
---

`SubjectConfigurer.enterSetFileName` (`src/main/java/com/laamella/deflower/SubjectConfigurer.java`, around lines 64-66) resolves the file name against `subject.basePath` twice. The second `resolve` is redundant. Harmless today.

Done when: the path is resolved once.

**Fix:** dropped the redundant second `resolve`; the first result (renamed `snapshotName` → `filename`, since it was already the resolved path, not just the name) is used directly. Verified with `mvn -o test`: 5/5 pass.
