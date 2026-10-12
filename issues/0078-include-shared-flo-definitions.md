---
title: Include shared definitions, such as the C64's I/O and KERNAL, in a .flo file
status: done
labels: enhancement
---

Every snapshot `.flo` file declares the same machine: the zero page used by BASIC and the KERNAL, the KERNAL workspace and vectors at `$0200-$0400`, the VIC-II, SID and CIA register blocks, color RAM, the BASIC and KERNAL ROMs and the KERNAL jump table. `zwark.flo`, `tcmine.flo` and `squirm.flo` each have a copy, about 100 lines, pasted from the previous one and edited slightly.

Want: a way to pull in shared definitions, e.g.

```
include c64.flo
```

with a `c64.flo` that ships with Deflower and declares the registers, ROM entry points and system areas with their usual names.

## To decide

- **Syntax and lookup.** An `include` line, relative to the `.flo` file, with built-in files found first or last.
- **Overriding.** A program often uses part of a shared area for itself (a zero page byte, the tape buffer). The local `.flo` line should win without an area conflict, which means included areas behave like placeholders, or the include has finer-grained pieces (`c64-zeropage.flo`, `c64-io.flo`, ...).
- **Banking.** Whether the ROMs are visible depends on `$01` ([0069](0069-one-label-per-address-ignores-banking.md), [0066](0066-snapshot-rom-areas-are-not-in-the-image.md)). The included file can't know; maybe separate files per configuration.
- **Unused names.** Labels for registers the program never touches clutter the output, as defines or `.virtual` blocks. Print only the ones that are referenced, or accept the clutter.

Done when: `zwark`, `tcmine` and `squirm` use the include instead of their copies, with their `expected.asm` unchanged or the changes reviewed with snipsert.

## Decisions

- **Syntax and lookup.** `include <file>` inside a run, after its `deflower` line. The path is relative to the including file; when no such file exists, a built-in file shipped with Deflower is used. Included files can include others, but can't contain `deflower` lines.
- **Overriding.** Included lines are weak. Any other line's area or label replaces an included one without an area conflict, whatever the order of the lines; an included element that overlaps a program's own area is dropped as a whole. An included area still stops the trace, like any other area.
- **Banking.** Built-in pieces: `c64_zeropage.flo`, `c64_system.flo` (`$0100-$0800`), `c64_io.flo`, `c64_basic.flo` and `c64_kernal.flo` (underscores: a `.flo` file name can't contain `-`), and `c64.flo`, which includes them all (the view with `$01` = `$37`). A program that banks a ROM out includes only the pieces it sees.
- **Unused names.** Included virtual areas and included labels on uncovered memory are only printed when the output refers to them: an instruction's operand or an `.addr` value. `.virtual` emits no bytes, so reassembly is unaffected. Included areas that aren't virtual are always printed.

## Closing note

`include <file>` (grammar, `FloReader`) reads the file next to the including one, else the built-in one from `src/main/resources/deflower/`, into the current run with its `Annotation`s marked `included`. A cycle, a missing file and a `deflower` line in an included file are parse errors. `SubjectConfigurer` applies the run's own lines first and the included ones after: an included label or comment only goes where there is none, and an included element overlapping an own area is skipped. An included comment goes only where its label does. After the flow analysis, `Subject.dropUnusedIncludes` removes the included virtual arrays no operand or `.addr` value points into, and the included labels nothing prints, with their comments.

The built-in files declare the named registers and locations as virtual elements, and fill the gaps with unnamed virtual ranges. Those only stop the tracing (into the RAM under the ROMs of a snapshot, say) and are never printed. ROM routines and the KERNAL jump table are labels on those ranges, so a used one prints as a define (`chrout = $ffd2`).

`zwark`, `tcmine` and `squirm` now include `c64.flo`, and keep only their own names. Their outputs assemble to the same bytes as before. Machine names now follow the include (`vic_screen` → `screen_ram`, `vic_sprite_coll` → `vic_sprite_collision`, `multicolor_1` → `background_color_1`, `vic_joystick1` → `cia1_port_b`), and every unused register, ROM and filler block is gone. zwark's decruncher in the stack page needs a placeholder line (`$0100-$01cd`), because a `code` entry alone doesn't override an included area.

Fixed along the way: a `jmp (pointer)` registered a new `addr` area over a pointer a `.flo` line already declared. That was a conflict with a `virtual addr` like `irq_vector`, and it split a declared `addr` table into single elements. It now keeps the declared area, and only follows a pointer the image loads. In `3dgolf_snap` the jump table stays one array, with its inner labels printed as defines; it assembles to the same bytes. The analyser also no longer auto-labels data inside an unnamed included range (`bit $02e6`, not `bit d02E6`).

New fixture `include`: a local include that includes `c64.flo`, own lines overriding included areas, labels and part of an array, and a `.addr` to a KERNAL routine. Its output reassembles to the `.prg`. Error cases are covered by `rejectsIncludeCycle`, `rejectsMissingInclude` and `rejectsRunInIncludedFile`.
