---
title: A data area on memory the image doesn't load prints as zero bytes
status: done
labels: bug
---

A data line on memory the image doesn't load registers its area like any other, and the output prints that memory as `.byte $00`. The `.asm` then puts bytes where the program had none. If the area lies outside the `.prg`, reassembling it makes a bigger binary, with a gap filled in between.

Found by the round trip of [0062](0062-snippet-test-factories.md): `blockoffset` loads a `.prg` at `$c000` and declares `$400 byte[48] screen`. The output was:

```
*=$0400

screen:
		.byte	$00, $00, $00, ...
```

The snippet now declares the array `virtual`, so it no longer shows the bug.

Exports already catch this case: "Exported table.bin at $c030 holds memory the image doesn't load". `FlowAnalyser` also stops at unloaded memory (`MemoryLocation.loaded`).

## To decide

- **What to print.** The options:
  - treat a typed area on unloaded memory as virtual, and print a `.virtual` block;
  - report an error, like the export check does;
  - print a warning and treat it as virtual.
- **Partly loaded areas.** What happens when an area is only partly loaded: split it, or apply the rule to the whole area?

Done when: a short snippet with a data area on unloaded memory gives the chosen output, and passes the round trip.

## Closing note

Warn and treat as virtual, decided per element. In `Subject.annotate`, a data element with any byte the image doesn't load is registered as virtual, so an array running past the image's end splits into data and a `.virtual` tail. A line from the `.flo` file itself (not an included one) prints one warning naming the unloaded ranges, e.g. "Warning: byte screen at $0400: the image doesn't load $0400-$0430, printed as virtual". Exports still report unloaded memory as an error.

The snippet `short/unloadeddata.txt` has an array wholly outside the `.prg` and a `word[3]` crossing its end, and passes the round trip. `blockoffset` keeps its `virtual`, since that snippet is about the operand offset.
