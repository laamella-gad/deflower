---
title: Load part of a file by a place and a type, to put a moved block where it runs
status: done
labels: enhancement
---

Programs copy routines to where they run: the stack page, the tape buffer, under the ROMs. Deflower traces bytes only where they load, so calls to the run address warn `goes into memory the image doesn't load`.

Found in The Write Stuff 128 (`~/dev/c64-productivity/tws128`):
- `$377f` copies `$378b-$3801` to `$0111`: the insert and delete move routines, called as `jsr $0111` and `jsr $014a`.
- `$258b` copies `$25e3-$260a` (zero-terminated) to `$0270`: three bank-to-bank byte copiers.

A `load` line already handles most of this: it loads the block a second time at its run address, inside the same run, so the code is traced there, calls resolve to its labels with cross-references, and the warning goes. The project cut the blocks out to `.bin` files with a throwaway Python script and gave them their own `deflower` runs instead, which made a second `.asm` whose labels don't connect.

The script is needed because `from` and `size` are refused on a `.prg` (`loaders.nim:38`, "from and size are for a .bin, not a .prg"). Decided: take the part by its address range, as everywhere else in a `.flo` file, so it can be copied from the disassembly or a verify `gap` line:

```
deflower bb_writer.prg
load bb1.prg $378b-$3801 at $0111
```

Consider at the same time replacing `size` (and maybe `from`) with the `[n]` count of a data line (`byte[123]`): `size` is a weaker version of the same idea. To decide:
- the form of a count: `$378b[$76]` next to `$378b-$3801`, and for a `.bin`, where there is no address yet, an offset form;
- whether `from`/`size` go (breaking existing `.flo` files) or stay as the `.bin` form;
- the same options on `--init`, `--dump`, `--find` and `--strings`.

Done when a `load` (and `deflower`) line takes a range of a `.prg`, with a short snippet, and `README.md` describes this use of `load` for code that runs at another address (the C64 skill notes too).

Out of scope, a possible follow-up: the copy at its load address still shows as data or a gap, and the output reassembles to the merged memory, not to the original `.prg` byte for byte. A `.logical`-like line ([0115](0115-code-that-overwrites-instructions.md), point 2) would cover that. [0137](0137-detect-copy-loops.md) could suggest the `load` line.

## Closing note

The image line reuses the annotation's place and type instead of `from`/`size` (removed): `<file> [<place> [<type>[<size>]]] [at <address>]`. A `.prg`'s part is a range of its addresses, a `.bin`'s of its offsets; a type sizes it like a data line (`$50 byte[$2000]`), and a place alone runs to the end of the file. `load game.prg $378b-$3801 at $0111` traces the moved code where it runs. The command line tools take the same options, parsed by the `.flo` parser (`flo_reader.readImageText`). Snippets `short/load_range.txt`, `short/loadbin.txt`, `short/invalid/load-*`; README under `deflower` and `load`. `.logical` output is left out of scope.
