---
title: Disassemble a region into a separate .asm file, included from the main one
status: open
priority: medium
labels: enhancement
---

All output for one `deflower` run goes into one file, `out/<binary>.asm`. For a large program it would help to split it: a music player, a level loader or a block of graphics data in its own source file, while the main file stays readable.

Want: mark a region in the `.flo` file so its disassembly (code and data, with the usual labels and defines) is written to its own file, e.g. `out/<name>.asm`. The main file gets a 64tass `.include "<name>.asm"` at that address instead.

Why `.include` works for this: 64tass includes a file as text at that point, so the two files share one symbol table. Labels defined in the included file resolve in the main file and the other way round, and `*=` origins keep working. Reassembling the main file still has to produce the same bytes as one big file.

Open questions:
- **Syntax.** Options:
  - reuse `export <id>`, which already parses. But [0022](0022-export-region-to-binary.md) plans it for writing a region as a binary file (`.binary`);
  - add a second keyword, e.g. `include <id>`;
  - one keyword where the type decides: `code`/typed data gives source, untyped gives binary.

  Choose together with 0022.
- **What a region is.** A range line (`$c000-$c800 ... include music`) is the obvious unit. A region may hold traced code, which the `.flo` file doesn't declare as an area. So the region is an address range for the writer, not an `Area`, and must not cause area conflicts with what is inside it.
- **Boundaries.** An instruction or a multi-byte element that straddles the region's edge: report an error, or move the edge?
- **Nesting.** A region inside a region (a file that includes another). Probably not needed at first.
- **Origins.** The included file needs its own `*=` at its start, because it may be assembled after a gap. The main file then needs a `*=` again after the `.include`.

Related: [0057](0057-watch-mode.md) should also rewrite the included files. `Deflower` clears `out/` per `.flo` file, so the extra files are cleaned up along with the main one.

Done when: a region marked in the `.flo` file is written to its own `.asm` file, the main file includes it at the right place, and a fixture shows that the main file assembles with 64tass to the same bytes as without the split.
