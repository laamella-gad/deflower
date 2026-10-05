---
title: Excessive System.out tracing
status: open
labels: cleanup
---

`Subject.storeAt` prints every stored byte (`System.out.println(""+(startAddress+i)+" "+...)`), so loading a 64K image prints 64K lines. `SubjectConfigurer`, `FlowAnalyser` and `Deflower.deflower` also print or have commented-out debug loops. Output noise hides the useful warnings (such as "Jumping into non-code area").

Done when: per-byte and per-instruction tracing is removed or moved behind a flag, and the remaining messages are one line per meaningful event.
