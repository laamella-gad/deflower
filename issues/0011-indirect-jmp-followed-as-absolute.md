---
title: JMP (indirect) is followed as if it were absolute
status: done
labels: bug
---

`FlowAnalyser.analyseCodeFlow` treated every `JMP` operand as a target address. For indirect mode (`JMP ($xxxx)`) the operand is a pointer, so the analyser labelled the pointer cell as code and never followed the real destination.

Fixed: when `instruction.addressingMode == AddressingMode.INDIRECT`, the pointer address is labelled and registered as a `DataArea` of the (previously unused) `DataType.POINTER`, and the actual jump target is read with `subject.wordAt(pointerAddress)` and followed instead.

Covered by `DeflowerTest#followsIndirectJmpTarget` using `src/test/resources/indirectjmp/indirectjmp.flo`: a 3-byte `JMP ($C010)` at `$C000`, a pointer at `$C010` holding `$C020`, and a small `LDA`/`RTS` routine at `$C020`. The expectation shows the pointer labelled (`_C010_POINTER`) but not decoded as code, and `$C020` correctly decoded.

Done when: indirect `JMP` reads the pointer and follows its target, and a test covers it. ✅
