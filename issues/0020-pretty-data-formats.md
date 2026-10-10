---
title: Add pretty disassembly formats for known data shapes (charset, screen, sprite)
status: open
priority: low
labels: enhancement
---

`ResultWriter`/`AssemblyFileFormat.print` only emits raw `.BYTE` lines (see also [0002](0002-only-byte-data-emitted.md)). Known C64 data shapes deserve dedicated, readable output instead of a flat byte dump, e.g.:

- **character set**: 8 bytes per char, printed as 8 binary rows (so the pixel art is visible in the source).
- **40x25 character screen**: bytes grouped into rows of 40.
- **sprite**: 63 bytes (3 per row x 21 rows) + 1 color/pointer byte, grouped into rows of 3.

These would need new `.flo` data types (or annotations on the existing `byte`/array syntax) so the user can mark a block as one of these shapes, and corresponding formatting in the writer.

Constraint: whatever is emitted must stay assembleable with **64tass** (the output is still a real `.asm` source, not just a human-readable comment) — so the pretty formatting has to use directives/syntax 64tass accepts (e.g. its binary byte literals, `%........`, for the charset/sprite bit patterns), not just cosmetic comments bolted onto `.BYTE`.

Done when: at least charset and screen blocks can be marked in a `.flo` file and come out formatted, and the resulting `deflowered.asm` still assembles under 64tass.

## Decisions

- **Syntax: new type keywords** `charset`, `screen` and `sprite`, alongside `char`/`byte`/`word`/`dword`. The size counts shapes, not bytes: `$2000 charset[64] font` is 64 characters of 8 bytes, `$3000 sprite[4] ship` is 4 sprites of 64 bytes (63 + 1 padding byte), `$0400 screen title` is one 1000-byte screen. They become reserved words.
- Output: charset and sprite rows as binary `.byte %00111100` lines (one row of 8 pixels, or 3 bytes for a sprite row), the screen as `.byte` rows of 40.
