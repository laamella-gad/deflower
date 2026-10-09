---
title: Generate lowercase assembly output (except user labels/comments)
status: open
labels: enhancement
---

Directives are already lowercase (`.byte`/`.word`/`.dword`/`.addr`, issue 0036/casing fix). The rest of `ResultWriter.java`'s generated text is still uppercase in several places, inconsistent with 64tass's own convention (every example in its manual uses lowercase):

- **Opcode mnemonics** - `printInstruction(...)`: `print(instruction.opcode.name())` prints the `Instruction.Opcode` enum's Java name as-is (`LDA`, `STA`, `RTS`, ...), always uppercase.
- **Index-register suffixes** - `", X"` / `", Y"` literals in the `operand` switch (`IND_X`, `IND_Y`, `ABSOLUTE_X`, `ABSOLUTE_Y`, `ZERO_PAGE_X`, `ZERO_PAGE_Y` cases).
- **Hex digits in `$`-prefixed literals** - `Printing.asHexByte`/`asHexWord`/`asHexDword`/`asAddress` all use `%02X`/`%04X`/`%08X` (uppercase hex digits), used throughout for immediate values, absolute addresses, and raw `.byte` dumps.

Not in scope - must stay exactly as-is, since they're either user-supplied or raw data, not generated syntax:
- Labels (`.flo`-given names, and auto-generated `_XXXX_DATA`/`_XXXX_CODE`/`_XXXX_POINTER` - the latter's own casing is a separate, deliberate convention, not assembler syntax).
- Comments (carried verbatim from `.flo` comment lines).
- Character literals (`asChar`'s `'A'`-style quoting) - that's the actual byte value being rendered, not generated syntax around it.

Scope: `ResultWriter.java`'s `printInstruction(...)` (opcode + index-register suffixes) and `Printing.java`'s hex-formatting helpers (digit casing). Check whether 64tass accepts/prefers lowercase hex digits too (not yet confirmed from the manual, unlike the directive-casing precedent) before changing `Printing`, since that file is shared and a case change there is more far-reaching than the two other spots.

Done when: a fresh fixture run shows lowercase opcodes (`lda`, `sta`, `rts`, ...), lowercase `, x`/`, y` suffixes, and (if confirmed correct for 64tass) lowercase hex digits (`$4a` not `$4A`) - with all affected `expected.asm` fixtures regenerated and reviewed to confirm the only changes are casing.
