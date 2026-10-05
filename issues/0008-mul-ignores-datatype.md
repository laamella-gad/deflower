---
title: n*m size ignores the datatype
status: open
labels: bug
---

`SubjectConfigurer.enterMul` (around line 125) uses `type.dataType.sizeInBytes` before `enterDatatype` runs. The walker enters the `mul` child before the `datatype` sibling, so `type` is still the `BYTE` default.

Reproduced with `$0810 4*2 word`: the log reports 4 words, expected 8.

Done when: `n*m <type>` marks `n*m` elements of that type, and a test checks it.
