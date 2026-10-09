---
title: LDA labels data only for absolute addressing
status: done
labels: enhancement
---

`FlowAnalyser.analyseCodeFlow` (`src/main/java/com/laamella/deflower/FlowAnalyser.java`, around line 59) labels a `DATA` target only for `LDA` in absolute mode. Other modes that reference data (`abs,X`, `abs,Y`, zero page, zero page indexed) get no label.

Also, `LDA` reaches the next instruction only because the inner `switch` has no `break` and control falls through to `default`. That works, but it is easy to break by accident.

Found by reading the code. Not reproduced.

Done when: data references in the other addressing modes get `DATA` labels, and the fall-through to the next instruction is explicit.

## Closing note

Decided scope: every data instruction, absolute modes only (`abs`, `abs,X`, `abs,Y`). In `FlowAnalyser.analyseCodeFlow`, the `LDA` case and its hidden fall-through are gone. All control-flow instructions already have their own cases, so the `default` branch now labels the operand of any absolute-mode instruction as data, then continues to the next instruction explicitly. That covers LDA/LDX/LDY/STA/STX/STY/CMP/CPX/CPY/ADC/SBC/AND/ORA/EOR/BIT/INC/DEC/ASL/LSR/ROL/ROR, and any illegal opcode with an absolute operand.

Two refinements came out of reviewing the output:

- **No auto-label where a name already exists** (`labelDataReference`). An address inside a labelled array, word or instruction already resolves as `label + offset`, and its own label would replace that. Squirm's `LDA _2657_DATA` now reads `LDA word_8_048e + $1`. That also fixed a real byte error: the old inline `_2649_DATA:`/`_2657_DATA:` labels inside a word assembled one byte too far, so seven squirm instructions reassembled with the wrong operand (noted on [0028](0028-mid-block-labels-as-address-defines.md)).
- **Labels on memory no area covers are used.** I/O registers, vectors and unused RAM get a `dXXXX` label too. As decided, `nameForAddress` now prints such a label even where there is no area, so `STA $D400` becomes `STA dD400`. The label definition sits in its own `*=` origin block. *Reversed by [0054](0054-empty-labels-on-uncovered-memory.md): those origin blocks were noise, so memory no area covers is no longer labelled and its operands stay numeric.*

Found and filed along the way:
- [0052](0052-auto-labels-are-64tass-local-labels.md) (done first): auto-labels started with `_`, which made them 64tass local labels.
- [0053](0053-force-absolute-operand-on-zero-page-label.md): absolute operands below `$100` reassemble as zero page.

Expectations regenerated: squirm, zwark, tcmine, multi/a, virtualarea. They differ only in the new data labels, their origin blocks, and runs of untyped bytes split up where code touches single bytes in them (fixable with `.flo` arrays). Reassembled with 64tass, compared with the previous expectations:
- tcmine, multi a/b, virtualarea and zwark (`-i`): same bytes;
- squirm: differs only in those seven corrected operands.

42/42 tests green.
