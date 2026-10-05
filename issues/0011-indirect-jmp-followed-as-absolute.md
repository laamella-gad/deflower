---
title: JMP (indirect) is followed as if it were absolute
status: open
labels: bug
---

`FlowAnalyser.analyseCodeFlow` (`src/main/java/com/laamella/deflower/FlowAnalyser.java`, around line 45) treats every `JMP` operand as a target address. For indirect mode (`JMP ($xxxx)`) the operand is a pointer, so the analyser labels the pointer cell as code and never follows the real destination.

Found by reading the code. Not reproduced. Needs a fixture with an indirect JMP to confirm.

Done when: indirect `JMP` reads the pointer and follows its target, and a test covers it.
