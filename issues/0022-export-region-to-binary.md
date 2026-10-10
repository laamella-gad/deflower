---
title: Mark regions for export to a binary file, included from the generated asm
status: open
priority: medium
labels: enhancement
---

The grammar already has an `export ID` expr alternative (`Flo.g4`, `# export`), but nothing implements it: no `enterExport` in `SubjectConfigurer`'s listener, so the rule is dead syntax today.

Want: tag an address or `$start-$end` range with `export <name>`, and have that region written out as a standalone binary file (e.g. `out/<name>.bin`), with the generated `deflowered.asm` referencing it via an assembler include directive (e.g. `.BINARY` / `.INCBIN`, whichever the target assembler syntax uses) at that address instead of inlining the bytes as `.BYTE` lines. Useful for charsets, sprites, music data, etc. that are more useful as a separate asset file than as disassembly noise.

Done when:
- `export <name>` on a line with an address or range registers the region for export (likely a new `Area` kind, or a flag on `DataArea`).
- `ResultWriter`/ `Deflower` writes the region's bytes to `out/<name>.bin`.
- `AssemblyFileFormat` emits an include line at that address pointing at `<name>.bin` instead of `.BYTE` data.
- A fixture + test covers an exported region: binary file exists with the right bytes, and the `.asm` output has the include line instead of inline bytes.

## Decisions

- **Syntax, shared with [0058](0058-disassemble-region-to-separate-asm-file.md): one keyword, `export`, and the file name's extension decides.** `$2000-$2800 export font.bin` writes the bytes to `out/font.bin` and puts 64tass's `.binary "font.bin"` at that address. `$c000-$c800 export music.asm` is 0058's source file. The `.flo` ID token already allows dots. Any other extension is an error.
