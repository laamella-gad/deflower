---
title: Rename `system` to `virtual` and emit 64tass `.virtual` blocks instead of address defines
status: open
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
