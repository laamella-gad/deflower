---
title: A second deflower line wipes earlier annotations
status: done
labels: bug
---

`SubjectConfigurer.clearMemory()` replaced every `MemoryLocation` on a second `deflower` line, so areas and labels set before it were lost.

Fixed by treating every `deflower` line as the start of its own fresh, independent run: a new `Subject` (own 64K memory, own `potentialCodeLocations`), with its own flow analysis pass, written to its own output file named after the binary it loads (e.g. `deflower foo.prg` writes `out/foo.asm`). `SubjectConfigurer.configure()` now returns a `List<Subject>`, and `Deflower.deflower()` runs the flow-analysis/write steps once per `Subject`. The `out` directory itself is still recreated once per `.flo` file, so one run's output doesn't delete another's.

Covered by `DeflowerTest#secondDeflowerLineStartsAFreshIndependentRun`, using `src/test/resources/multi/multi.flo` (two `deflower` lines, each with its own code entry; the second also has an extra data annotation), asserting each run's labels/annotations don't leak into the other's output file.

Done when: a second `deflower` line either keeps earlier annotations or is rejected with a clear error, and a test covers the chosen behaviour. ✅ Chosen behaviour: each `deflower` line gets its own independent run and output file.
