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
- **Syntax.** [0022](0022-export-region-to-binary.md) is done: `export <file>.bin` and `export <file>.prg` on a data line write the region as a binary. The natural extension is to let the extension decide here too, `export <file>.asm` giving source. But `export` today makes the region fixed data, and a source region holds traced code, so it would need a range line that isn't a data line (see [0085](0085-export-code-region.md), which asks the same for code exported as a binary). `include` is taken by `.flo` includes.
- **What a region is.** A range line (`$c000-$c800 ... include music`) is the obvious unit. A region may hold traced code, which the `.flo` file doesn't declare as an area. So the region is an address range for the writer, not an `Area`, and must not cause area conflicts with what is inside it.
- **Boundaries.** An instruction or a multi-byte element that straddles the region's edge: report an error, or move the edge?
- **Nesting.** A region inside a region (a file that includes another). Probably not needed at first.
- **Origins.** The included file needs its own `*=` at its start, because it may be assembled after a gap. The main file then needs a `*=` again after the `.include`.

Related: [0057](0057-watch-mode.md) should also rewrite the included files. `Deflower` clears `out/` per `.flo` file, so the extra files are cleaned up along with the main one.

## Example: 2krace's music player

Fixture `2krace_snap` has a good candidate. Its music player, `$1000-$1592`, is standalone. It has a jump table (`music_init`, `music_play`, `music_set_volume`), its own code, channel state, frequency tables, instruments, order lists and patterns. The game calls only `music_init` and `music_play`. Outside its own region, the player touches only the SID registers and the zero-page `music_pointer` (`$d0`). Both are declared in the main file, so labels would cross the file boundary in both directions. Gaps of unused memory lie on both sides of it (`$0da0-$0fff` before, `$1592-` after), so no instruction or element crosses its edges. With this feature, the line would be:

```
$1000-$1592 export music.asm
```

`out/2krace_snap.asm` would then hold `.include "music.asm"` where the player is now. Through the shared symbol table, the game's `jsr music_init` would resolve to the included file, and the player's `sta voice1_control` to the main file. A fixture made from this would cover a code region with traced code, data tables and self-modified operands (`init_flag`, `filter_steps`, ...) all inside one exported file.

Done when: a region marked in the `.flo` file is written to its own `.asm` file, the main file includes it at the right place, and a fixture shows that the main file assembles with 64tass to the same bytes as without the split.

## Decisions

- **Syntax, shared with [0022](0022-export-region-to-binary.md): one keyword, `export`, and the file name's extension decides.** `$c000-$c800 export music.asm` writes that region's disassembly to `out/music.asm` and puts `.include "music.asm"` in the main file; `export font.bin` is 0022's binary file. No separate `include` keyword.
- **Boundaries: report an error.** An instruction or multi-byte element that straddles the region's edge is reported like an area conflict (e.g. "Region music.asm ends inside the instruction at $C7FF"), and no output is written. The edge is never moved silently.
