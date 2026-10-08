---
title: Annotations before the deflower line throw NullPointerException
status: done
labels: bug
---

`Subject.memory` is null until `enterSetFileName` runs. Any annotation line that comes before the `deflower <file>` line reaches `Subject.registerBlock` and throws `NullPointerException` (`SubjectConfigurer.java`, around line 145).

Reproduced with `$0800-$080f byte` placed above `deflower t.prg`.

Done when: annotations before `deflower` either work or fail with a clear error that names the line.

Fix: made it fail with a clear error instead of making it work. `deflower` loads the memory image that every annotation addresses, and [0010](0010-second-deflower-wipes-annotations.md) already proposes `deflower` being required as the first line of the file, so "annotations before deflower work" isn't the direction this is headed. `exitLine` now checks `subject.memory != null` first and throws `IllegalStateException` naming the line number and text, e.g. `Line 1 is an annotation, but no memory image has been loaded yet: ... The 'deflower <file>' line must come before any annotation.` Verified with a scratch `.flo` fixture that puts an annotation above `deflower`; full `mvn -o test` still passes unchanged.
