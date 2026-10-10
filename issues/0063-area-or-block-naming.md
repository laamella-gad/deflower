---
title: Choose between the names "area" and "block"
status: done
labels: cleanup
---

The code uses two words for the same thing, a stretch of memory with one meaning (an instruction, or one data element):

- **area**: the classes `Area`, `DataArea` and `InstructionArea`, `MemoryLocation.area`, `ResultWriter`'s `currentArea`/`lastArea`, `FlowAnalyser.runsIntoExistingArea`, the "Area conflict" error, and CLAUDE.md and the `Flo.g4` header ("area conflict").
- **block**: `Subject.registerBlock`, the `LineType` constants (`CHAR_BLOCK`, `BYTE_BLOCK`, `WORD_BLOCK`, `DWORD_BLOCK`, `ADDR_BLOCK`, `UNKNOWN_BLOCK`), the parameter name of most methods that take a `DataArea` or `InstructionArea` (`print(DataArea block, ...)`, `printInstruction(InstructionArea block, ...)`, `continuesRun(DataArea block, ...)`, `instructionBlock`), and the "Marking block of ..." tracing.

"Block" also means other things in this project, which makes the double use more confusing:
- the `{ }` block syntax in the `.flo` file ([0035](0035-implement-offset-block-syntax.md), `endBlock` in the grammar);
- 64tass's own `.block` and `.virtual` blocks in the output;
- a basic block in control-flow terms, which may come up in [0034](0034-support-hi-lo-byte-extraction-operators.md).

Pick one word for "memory with one meaning" and rename the other uses to it. "Area" is the more established one (it's the class hierarchy and the error message), and it leaves "block" free for the `{ }` syntax.

Also decide whether the `LineType` constants need the suffix at all: they name the kind of a `.flo` line, not an area, so `BYTE`/`WORD`/... or `BYTE_LINE` may fit better.

Done when: one word is chosen, the code, tracing, CLAUDE.md and the grammar header use only that word for it, and all tests still pass with unchanged `expected.asm` files (the tracing text is not part of them).

## Decisions

- **"Area".** It names memory with one meaning everywhere: `registerBlock` becomes `registerArea`, parameters named `block` or `instructionBlock` that hold an area become `area`/`instructionArea`, and the tracing says "Marking area of ...". The class names and the "Area conflict" error stay. "Block" is left for the `{ }` syntax ([0035](0035-implement-offset-block-syntax.md)) and 64tass's own blocks.
- **`_LINE` suffix for `LineType`.** The constants name the kind of a `.flo` line: `CHAR_LINE`, `BYTE_LINE`, `WORD_LINE`, `DWORD_LINE`, `ADDR_LINE`, `UNKNOWN_LINE` and `CODE_LINE` (was `CODE_ENTRY`).

## Closing note

Renamed as decided:
- `Subject.registerBlock` is now `registerArea` (callers in `Subject` and `FlowAnalyser`, references in `Area`'s Javadoc and `DeflowerTest`).
- Every parameter or local named `block`/`instructionBlock` that holds an area is now `area`/`instructionArea` (`ResultWriter`, `FlowAnalyser`, `Subject.continuesRun`/`continuesArray`, where the existing local `area` became `next`).
- The `LineType` constants are `CHAR_LINE`, `BYTE_LINE`, `WORD_LINE`, `DWORD_LINE`, `ADDR_LINE`, `UNKNOWN_LINE` and `CODE_LINE`.
- The tracing says "Marking area of ...". Comments that used "block" for an array or a data run now say "array" or "run".
- CLAUDE.md and the open issues 0059 and 0062 follow.

"Block" still names the `{ }` syntax in the grammar, 64tass's `.virtual` blocks and an output section after a `*=` origin ("origin block"), none of which is an area. The VICE snapshot reader's own "block" is left as is.

`mvn -o test`: 48 tests green, no `expected.asm` changed.
