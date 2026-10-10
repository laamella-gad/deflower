---
title: Include shared definitions, such as the C64's I/O and KERNAL, in a .flo file
status: open
priority: medium
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
