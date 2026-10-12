---
title: Mark regions for export to a binary file, included from the generated asm
status: done
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
- **Which lines:** any data line, a range or a typed array (`$2000 byte[2048] export font.bin`, `$2000-$2800 font export font.bin`). The type only sets the size and how operands name it (`font + $8`); the output is always `.binary`. `code`, `virtual`, a plain address, an included line or a file name without `.bin` is an error, as is the same file name twice in one `.flo` file. Exporting code is [0085](0085-export-code-region.md).
- **Region:** fixed data. Even an untyped exported range is not a placeholder: tracing stops at it, and another typed line inside it is an area conflict. Label-only lines inside it are printed as `label = $xxxx` defines after the `.binary` line.

## Closing note

`FloReader` checks the export line and puts the file name on the `Annotation`. `Subject.annotate` registers an `ExportRegion` (reporting one that holds memory the image didn't load or runs past $ffff) and gives each of the line's `DataArea`s a reference to it; such an area is never a placeholder, and its file name takes part in `equals`. `AssemblyFileFormat.printExport` prints the label and comment, `.binary "<file>"`, then the annotations inside as defines, and `ResultWriter` skips to the region's end. `Deflower` writes each region's bytes next to the `.asm` file. Afterwards, `.prg` was added as a second extension: the file starts with the region's start address as its load address, and the output skips it with `.binary "<file>.prg", 2` (`ExportRegion.headerSize`). Fixture `export` covers an untyped `.bin` and a typed `.prg` export, a label and an auto label inside one, and reassembles with 64tass to the `.prg`'s bytes; `invalid/export-*.flo` and `exportunloaded` cover the errors.
