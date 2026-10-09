---
title: Rename `system` to `virtual` and emit 64tass `.virtual` blocks instead of address defines
status: done
labels: enhancement
---

Since issue 0045, `system` marks memory that the code references but whose contents aren't part of the program, so no
bytes are emitted and only labels are defined. The name fits hardware (VIC/SID/CIA registers, colour RAM) but not the
other memory that needs exactly the same treatment: zero-page and other RAM variables (`squirm.flo`'s
`player_direction`, `new_loc_lo`, ... at `$0057`-`$00fe`), screen RAM used as program state, ROM entry points. What
the flag controls is "don't emit the contents", not "this is system hardware", so the keyword should say that.

## Proposal

**Rename the keyword to `virtual`**, after 64tass's own `.virtual`/`.endv` block, which declares labels and reserves
space without emitting bytes. The `.flo` keyword then matches what it produces. Keep `system` as a deprecated alias for
a while, or drop it outright. Decide while doing it.

**Emit `.virtual` blocks instead of `name = $XXXX` defines.** The current defines keep the address but lose the declared
type and size. 64tass can keep both:

```
.virtual $0057
player_direction  .byte ?
joy_dir_for_move  .byte ?
.endv

.virtual $0400
screen_ram        .fill 1000
.endv
```

- `.byte ?` / `.word ?` / `.dword ?` reserve one value without output. An array (`byte[1000]`) becomes `.fill n` with
  n = size in bytes, or a repeated `?` list. Pick whichever 64tass handles best and reads well.
- Contiguous virtual areas share one block, opened/closed the same way `*=` origin runs work in the main output.
  Whether blocks sit at the top of the file or inline at their address position is open: inline keeps address order,
  the top keeps them out of the way of the program.
- References keep working by name, including `screen_ram + $50`. Automatic labels inside a virtual area
  (`_0423_DATA`) still need defining. Inside a block they can become their own `.byte ?` line, or stay a define.

**Keep memory roles separate from emission.** If I/O vs RAM-variable vs ROM ever needs distinguishing (for
documentation, or the pretty formats in issue 0020), add that as a separate tag later. Don't overload this flag again.

## Scope

- Grammar: `'virtual'` token (plus `'system'` if kept as an alias), and the listener handler.
- `DataArea.system` → `virtual`, and `Area.isSystem()` → `isVirtual()`.
- `ResultWriter`: replace `printSystemDefine` with `.virtual` block output.
- Fixtures: convert `zwark.flo`, `squirm.flo` and `systemarea` (rename to `virtualarea`?), and mark squirm's zero-page
  variables `virtual byte`.

Done when: `virtual` lines produce `.virtual` blocks with typed reservations and their labels; code references still
resolve; squirm's zero-page variables no longer appear as `.byte` data; all affected `expected.asm` files are
regenerated and reviewed (snipsert), with instructions unchanged apart from operands newly resolving to names.

## Closing note

Done.

Decisions taken:
- **`system` dropped outright, no alias.** All fixtures were converted, and keeping an alias would only preserve the misleading name.
- **Blocks are placed inline at their address position,** not collected at the top. Address order is kept, and the block slots into the main loop the same way `*=` runs do.
- **Runs use `.fill n`.** A run of more than one same-type element becomes `.fill n`, with n in bytes; that is 64tass's uninitialised reservation when the fill value is omitted. A single value becomes `.byte ?` / `.word ?` / `.dword ?` / `.addr ?` (CHAR and UNKNOWN use `.byte`). A run breaks at any label or comment, so every label gets its own reservation line, automatic labels such as `_0423_DATA` included.
- **A label inside a multi-byte element** (e.g. the second byte of a virtual `word`) has no reservation to attach to. It is printed as `name = $XXXX` inside the block.

Changes:
- Grammar: `'virtual' # setVirtual` replaces `system`.
- Listener and classes: `enterSetVirtual` in the listener. In the classes, `DataArea.virtual` and `Area.isVirtual()` replace their `system` counterparts.
- `ResultWriter`: `printVirtualStretch` replaces `printSystemDefine` and the separate defines pass. After `.endv` a fresh `*=` follows.
- CLAUDE.md now names the `virtual` keyword.

Fixture `systemarea` became `virtualarea` (test `virtualAreaBecomesVirtualBlockInsteadOfData`). It adds a zero-page `virtual word ptr` and a label at `$d801` inside the `color_ram` array. The output shows `ptr: .word ?`, the run split into `color_ram: .byte ?` / `second_color: .fill 3`, and code resolving `STA ptr`, `STA color_ram + $2`, `STA border_color`.

`squirm.flo`'s zero-page variables (`$0057`-`$00fe`) are now `virtual byte`.

Review with snipsert:
- squirm and zwark: every instruction line, operands included, is identical (checksum match).
- The defines at the top became `.virtual` blocks at their addresses, with sizes adding up correctly (e.g. squirm's `screen_ram` block: 35 + 1 + 817 + 137 + 1 + 1 + 8 = 1000).
- squirm's zero-page `.byte` dumps became `.byte ?` reservations.

28/28 green.
