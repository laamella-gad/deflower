---
title: Address range end is off by one
status: open
labels: bug
---

`SubjectConfigurer.exitLine` (`src/main/java/com/laamella/deflower/SubjectConfigurer.java`, around line 141) computes `amount = (addressEnd - address) / size`. Ranges are inclusive (`$0800-$080f` means 16 bytes), so the last byte is never marked and gets no data area.

Reproduced with a `.prg` and `$0800-$080f byte`: the log reports "Marking block of 15 byte".

Done when: `$0800-$080f byte` marks 16 bytes, and a test checks it.
