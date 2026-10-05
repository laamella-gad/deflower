---
title: LDA labels data only for absolute addressing
status: open
labels: enhancement
---

`FlowAnalyser.analyseCodeFlow` (`src/main/java/com/laamella/deflower/FlowAnalyser.java`, around line 59) labels a `DATA` target only for `LDA` in absolute mode. Other modes that reference data (`abs,X`, `abs,Y`, zero page, zero page indexed) get no label.

Also, `LDA` reaches the next instruction only because the inner `switch` has no `break` and control falls through to `default`. That works, but it is easy to break by accident.

Found by reading the code. Not reproduced.

Done when: data references in the other addressing modes get `DATA` labels, and the fall-through to the next instruction is explicit.
