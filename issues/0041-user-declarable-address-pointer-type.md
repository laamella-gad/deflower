---
title: Allow annotating a `.flo` line with type `address`/`pointer`
status: done
labels: enhancement
---

`DataType.POINTER` already exists and prints as `.addr` (issue 0036), but it's only ever created internally by `FlowAnalyser` for an indirect `JMP`'s target. There's no `.flo` keyword for it - `Flo.g4` only lexes `char`/`byte`/`word`/`dword`/`code` (`CHAR`/`BYTE`/`WORD`/`DWORD`/`CODE` tokens). A user who wants to annotate a known 16-bit address value by hand (a jump table entry, a vector, a pointer into a data structure) has no way to say that - the closest is `word`, which prints as plain `.word $XXXX` instead of resolving to a label the way `POINTER`/`.addr` does via `nameForAddress`.

Scope:

- Add a grammar token/keyword - `address` or `pointer` (pick one; `address` matches 64tass's own `.addr` terminology more directly, `pointer` matches the existing `DataType.POINTER` enum name) - alongside `CHAR`/`BYTE`/`WORD`/`DWORD` in `Flo.g4`.
- `SubjectConfigurer`: new `LineType` case mapping the keyword to `DataType.POINTER`, registered the same way the other data-block types are.
- `ResultWriter.java` needs no change - `print(DataArea, ...)`'s existing `case POINTER:` already does the right thing (`.addr` + label-or-hex via `nameForAddress`).
- A `word_2_048e`-style element that's actually a pointer (squirm/zwark both have screen-code data and sprite pointers already using plain `word`) is a candidate for a fixture, or a small dedicated one.

Done when: a `.flo` line like `$2000 address jump_table[4]` registers a `POINTER` area and the output shows `.addr` with resolved labels, same as the auto-generated indirect-JMP case.

## Decisions

- **Keyword `addr`**, matching 64tass's `.addr` and as short as `byte`/`word`: `$2000 addr[4] jump_table`. It maps to `DataType.POINTER` and becomes a reserved word.

## Closing note

Added the `addr` keyword: an `ADDR` token in `Flo.g4` (so it is a reserved word), `LineType.ADDR_BLOCK` mapped to `DataType.POINTER` in `FloReader`, and `ADDR_BLOCK` in `Subject.annotate`'s data-block case. `ResultWriter` needed no change. The grammar's format comment and CLAUDE.md list the new type.

Each element prints the label at the address it holds, or the hex address when there is none; targets are not auto-labelled or traced (tracing is [0038](0038-rta-return-address-table-detection.md)'s `rta`).

New fixture `addrtype` (`$c000 addr[3] vectors`, two entries pointing at labelled code, one at unlabelled `$D020`) prints `.addr first, second, $D020`; test `emitsUserDeclaredAddrWithLabels`. `mvn -o test`: 48 tests green. Its `expected.asm` reassembles with 64tass to the `.prg` minus its header.
