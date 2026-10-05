---
title: Annotations before the deflower line throw NullPointerException
status: open
labels: bug
---

`Subject.memory` is null until `enterSetFileName` runs. Any annotation line that comes before the `deflower <file>` line reaches `Subject.registerBlock` and throws `NullPointerException` (`SubjectConfigurer.java`, around line 145).

Reproduced with `$0800-$080f byte` placed above `deflower t.prg`.

Done when: annotations before `deflower` either work or fail with a clear error that names the line.
