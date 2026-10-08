---
title: Excessive System.out tracing
status: done
labels: cleanup
---

`Subject.storeAt` prints every stored byte (`System.out.println(""+(startAddress+i)+" "+...)`), so loading a 64K image prints 64K lines. `SubjectConfigurer`, `FlowAnalyser` and `Deflower.deflower` also print or have commented-out debug loops. Output noise hides the useful warnings (such as "Jumping into non-code area").

Done when: per-byte and per-instruction tracing is removed or moved behind a flag, and the remaining messages are one line per meaningful event.

**Fix:** `Subject.storeAt` no longer prints anything; the per-byte `System.out.println` is gone and nothing replaces it. Confirmed with `deflowerSquirm` (which loads a full 64K snapshot): the 65536-line byte dump is gone from the output.

Also removed the dead commented-out debug loop in `Deflower.deflower` (a `do { ... } while(true)` wrapper with a commented timestamp print) and a dead commented-out per-instruction trace line in `FlowAnalyser.analyseCodeFlow`.

The rest of the `System.out` calls surveyed (file reads, "Marking block of...", "Will disassemble from...", "Jumping into non-code area", VICE header info) are already one line per meaningful event, so left as-is - they're informational tracing, not per-byte/per-instruction noise, and removing them is really issue [0006](0006-dead-parseline.md)/general cleanup territory, not this bug.

Verified with `mvn -o test`: 5/5 pass, all three `expected.asm` files unchanged (output content doesn't depend on console logging).
