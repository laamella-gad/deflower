---
title: Generate lowercase assembly output (except user labels/comments)
status: done
labels: enhancement
---

Directives are already lowercase (`.byte`/`.word`/`.dword`/`.addr`, issue 0036/casing fix). The rest of `ResultWriter.java`'s generated text is still uppercase in several places, inconsistent with 64tass's own convention (every example in its manual uses lowercase):

- **Opcode mnemonics** - `printInstruction(...)`: `print(instruction.opcode.name())` prints the `Instruction.Opcode` enum's Java name as-is (`LDA`, `STA`, `RTS`, ...), always uppercase.
- **Index-register suffixes** - `", X"` / `", Y"` literals in the `operand` switch (`IND_X`, `IND_Y`, `ABSOLUTE_X`, `ABSOLUTE_Y`, `ZERO_PAGE_X`, `ZERO_PAGE_Y` cases).
- **Hex digits in `$`-prefixed literals** - `Printing.asHexByte`/`asHexWord`/`asHexDword`/`asAddress` all use `%02X`/`%04X`/`%08X` (uppercase hex digits), used throughout for immediate values, absolute addresses, and raw `.byte` dumps.

Not in scope - must stay exactly as-is, since they're either user-supplied or raw data, not generated syntax:
- Labels (`.flo`-given names, and auto-generated `dXXXX`/`lXXXX`/`pXXXX` - the latter's own casing is a separate, deliberate convention, not assembler syntax).
- Comments (carried verbatim from `.flo` comment lines).
- Character literals (`asChar`'s `'A'`-style quoting) - that's the actual byte value being rendered, not generated syntax around it.

Scope: `ResultWriter.java`'s `printInstruction(...)` (opcode + index-register suffixes) and `Printing.java`'s hex-formatting helpers (digit casing). Check whether 64tass accepts/prefers lowercase hex digits too (not yet confirmed from the manual, unlike the directive-casing precedent) before changing `Printing`, since that file is shared and a case change there is more far-reaching than the two other spots.

Done when: a fresh fixture run shows lowercase opcodes (`lda`, `sta`, `rts`, ...), lowercase `, x`/`, y` suffixes, and (if confirmed correct for 64tass) lowercase hex digits (`$4a` not `$4A`) - with all affected `expected.asm` fixtures regenerated and reviewed to confirm the only changes are casing.

## Decisions

- **Everything generated becomes lowercase except labels:** mnemonics (`lda`), index suffixes (`, x`/`, y`) and hex digits (`$c0a2`, `.byte $4a`; 64tass reads hex digits in either case). User labels, comments and auto-labels (`lC0A2`, `dC0A2`) stay as they are.

## Closing note

Lowercased as decided:
- mnemonics: `printInstruction` prints `opcode.name().toLowerCase()`;
- index suffixes: `, x`/`, y` in the operand switch;
- hex digits: `Printing`'s helpers and the operand, `.addr` and `label + $offset` formats use `%x`, so `*=$c000`, `.virtual $00a2`, `.byte $4a`, `#$0f`, `label = $d020`, `@w $00ff`.

Auto-labels keep their uppercase digits (`lC0A2`, `dC0A2`, `aC010`), as do user labels and comments. `Printing` is also used by the error messages, so those print lowercase hex too (`Area conflict at $c001`, `run past $ffff`); the tests asserting them follow. CLAUDE.md and 0062's example follow.

Verification: all 21 `expected.asm` files regenerated; each differs from its old version only in letter case (compared case-folded). `mvn -o test`: 48 tests green. 64tass checks: the small fixtures that round-trip to their `.prg` still do; blockoffset, indirectjmp, narrowplaceholder, partialoverlap and tcmine don't (untraced bytes are skipped with `*=`), but reassemble to the same bytes as their old expectations; squirm and zwark (with `-i`) match their RAM images with 0 differing bytes.
