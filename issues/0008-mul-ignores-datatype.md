---
title: n*m size ignores the datatype
status: done
labels: bug
---

`SubjectConfigurer.enterMul` used `type.dataType.sizeInBytes` before `enterDatatype` ran. The walker enters the `mul` child before the `datatype` sibling, so `type` was still the `BYTE` default.

Fix: `enterMul` now sets `amount = left * right` directly instead of computing a size-dependent `addressEnd`. `exitLine` already multiplies `amount` by the datatype's size when building the `DataArea`s, and it runs after `enterDatatype`, so it has the right size.

Reproduced before the fix with `$0810 4*2 word` (4 words, expected 8) and confirmed fixed (8 words) with a scratch harness. None of the three test fixtures use `n*m`, so `mvn -o test` passes unchanged — this path has no coverage yet.
