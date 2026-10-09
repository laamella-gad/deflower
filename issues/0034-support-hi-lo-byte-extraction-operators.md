---
title: Support tass64's `<`/`>` hi/lo byte extraction operators in output
status: open
labels: enhancement
---

tass64 (https://tass64.sourceforge.net/, "Bit string extraction operators") has prefix operators for pulling one byte out of a 16-bit value: `<expr` is the low byte, `>expr` is the high byte (e.g. `lda #<label`, `ldy #>label`). Right now deflower has no equivalent, and the `.flo`/output conventions work around that in two ways that this operator would remove:

1. **Separate `_lo`/`_hi` labels.** `squirm.flo` (and others) declare two labels for one logical 16-bit value split across two bytes, e.g. `snk_head_loc_lo` / `snk_head_loc_hi` at consecutive addresses. Code that does `LDA snk_head_loc_lo` / `LDA snk_head_loc_hi` could instead read `LDA #<snk_head_loc` / `LDA #>snk_head_loc` against a single `word` (or `pointer`) declaration - one label instead of two, and the name itself stops needing to encode which half it is.

2. **`label + $01`-style offsets.** `nameForAddress` (`ResultWriter.java`) resolves an operand that lands one byte into a labeled `word`/array as `label + $01` (issue 0024's fix). When that "+1" is specifically the high byte of a 16-bit value (a `word`/`pointer` area, or any 2-byte element), `>label` is the more meaningful rendering than a raw offset - it says *what* the byte is (the high half of this address), not just *where* it is.

Scope to figure out:

- **Recognizing the case.** `>label` only makes sense when the operand's address is exactly `area.address + 1` of a `word`/`pointer`-typed `DataArea` (or `+1`/`+2`/`+3` of a `dword`) - needs distinguishing from an arbitrary `label + $01` into a `byte`/`char` array, which should keep printing as a plain offset.
- **Where it plugs in.** Likely `nameForAddress` in `ResultWriter.java` for existing `word`/`dword`/`pointer` areas (case 2) is the smaller, mechanical part. Collapsing an existing `_lo`/`_hi` label pair declared via two separate `.flo` lines into one `word` declaration (case 1) is a bigger, more "AI-assisted-refactor" kind of change to an existing `.flo` file - probably starts as a recommendation/detection (flag the pattern) rather than an automatic rewrite.
- **Addressing modes that take it.** tass64's `<`/`>` are general expression operators, usable wherever a byte-sized operand is expected - immediate (`#<label`), but also zero-page-style operands if the low/high byte happens to be used as an address itself. Deflower's own operand rendering (`AssemblyFileFormat.printInstruction`'s `operand` switch) would need to apply it only where it's actually correct (an IMMEDIATE byte that is in fact one half of a known 16-bit value - the common 6502 "set up a pointer" idiom: `LDA #<label` / `STA ptr` / `LDA #>label` / `STA ptr+1`).

Done when: an operand that reads the low or high byte of a known 2-byte area prints as `<label`/`>label` instead of a bare `label + $01` offset or a separately-declared `_lo`/`_hi` label, with a fixture covering the classic "set up a 16-bit pointer via two immediate loads" idiom.
