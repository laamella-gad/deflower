---
title: The `system` keyword is parsed but ignored, so system areas are dumped as data
status: done
labels: bug
---

`Flo.g4` accepts `system` as an `expr` alternative (`'system' # setSystem`), but `SubjectConfigurer`'s listener has no
`enterSetSystem` handler. Its `isSystem` field is only ever set to `false`, at declaration and in `startNewLine()`, so
every `DataArea` is created with `isSystem = false`. `git log -S enterSetSystem` shows a handler never existed.

The skip logic downstream is therefore dead code: `ResultWriter.print(DataArea, ...)`'s `if (block.isSystem) return;`,
the `isSystem` checks in `printAnnotation`/`isSingleValueRun`, and the `isSystem` part of `DataArea.equals`.

Visible effect: memory-mapped hardware and system RAM declared `system` is dumped into the generated asm as `.byte` data
from the snapshot, as if it were part of the program:

- `squirm.flo`: `$d800 system byte[1000] color_ram` prints all 1000 colour-RAM bytes (with the old single-byte
  declaration it printed `color_ram: .byte $00`).
- `zwark.flo`: `vic_screen` (`$0400`, 1000 bytes), `sprite_pointers`, `vic_color_ram` (`$d800`, 1000 bytes), the VIC/SID/CIA
  registers, ... are all dumped the same way.

Fix: add the handler.

```java
@Override
public void enterSetSystem(FloParser.SetSystemContext ctx) {
    isSystem = true;
}
```

Then decide what a system area should emit instead of data. It must keep its label, because code references it
(`STA color_ram, X`). Right now, with the bytes skipped, the label would still be printed as `color_ram:` under a
`*=$D800` origin. That assembles to the right address, but it puts an origin into I/O space for no reason. The cleaner
output is an address definition, e.g. `color_ram = $d800`, collected at the top of the file or wherever issue 0028
(labels inside larger areas as address defines) settles. Labels that land inside a system array (`vic_sprite_coords +
$2`) must still resolve.

Done when: `system` lines set `isSystem`; system areas produce no `.byte` output but their labels stay defined and
referenceable; a fixture/test covers a `system` area referenced from code; `squirm/expected.asm` and
`zwark/expected.asm` are regenerated and reviewed (snipsert), with the only changes being the removed system data and
its replacement label definitions.

## Closing note

Done.

- **`SubjectConfigurer`:** added an `enterSetSystem` handler that sets `isSystem = true`.
- **`ResultWriter.write`:** now makes two passes.
  - The first pass prints every label (and comment) that sits on a system area as an address definition at the top of the file, e.g. `color_ram = $D800`.
  - The main pass then treats system areas like unannotated gaps: no `.byte` output, no `label:`, and a fresh `*=` after them.
  - Elements inside a system array still resolve through `labelFor` (`color_ram + $2`), because the array label is defined.
  - The checks that became dead code were removed: the `isSystem` early-return in `print(DataArea, ...)` and the one in `printAnnotation`.

New fixture `systemarea`, tested by `systemAreaBecomesAddressDefinitionInsteadOfData`. It has a commented `system byte`, a `system byte[4]`, and code that stores to the single area, to an element inside the array, and to an unannotated I/O address. The output shows the comment and both defines up top, and `STA border_color`, `STA color_ram + $2`, `STA $D400` in the code.

Review with snipsert:
- **zwark:** the 12 system areas became defines, and their data dumps and origins were removed (129 `.byte` lines, including the full `vic_screen` and `vic_color_ram`).
- **squirm:** `color_ram` became a define, and its 1000-byte dump was removed.
- In both fixtures, every instruction line, operands included, is identical (checksum match). Code references keep their names.

28/28 green.
