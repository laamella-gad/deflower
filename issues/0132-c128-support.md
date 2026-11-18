---
title: Disassemble C128 programs: snapshots, includes and --init
status: done
labels: enhancement
---

Found disassembling The Write Stuff 128 v1.83 (`~/dev/c64-productivity/tws128`), a C128 word processor in three PRGs (`bb writer` at `$1c01`, `bb1` at `$2500`, `bb2` at `$3820`). Deflower traces the code fine from the PRGs, but nothing around it knows the C128:

- **Snapshots.** `loaders.nim:75` looks for the `C64MEM` module and fails with `No C64MEM found.` on an x128 snapshot. An x128 `.vsf` holds `C128MEM` with two 64K RAM banks plus the MMU registers. Taking a snapshot after the program has set itself up would give the relocated helpers at `$0111`, `$0200-$02a0` and the KERNAL's RAM routines for free, which the PRGs don't have.
- **Includes.** There are only `c64*.flo` built-ins. The project wrote its own `c128.flo`, `c128_io.flo` (VIC-IIe, SID, MMU `$d500-$d50b`, VDC `$d600/$d601`, CIAs, `$ff00-$ff04`), `c128_kernal.flo` (the editor jump table at `$c000-$c02d`, the KERNAL jump table `$ff47-$fff3` with `jsrfar`, `indfet`, `primm`, ...) and `c128_zeropage.flo`. These can become built-ins once checked against the ROM listing.
- **`--init`.** For a `.prg` at `$1c01` (C128 BASIC start) it should read the BASIC stub's `SYS` as on the C64 (`bb writer` has `SYS 7250`, `$1c52`), and offer `include c128.flo`.

Decided: all of it is wanted (includes, `--init` for `$1c01` PRGs, x128 snapshots), plus the bank label design of [0139](0139-memory-in-other-banks.md). A snapshot run takes bank 0; `deflower game.vsf bank 1` takes bank 1 as a run of its own. [0069](0069-one-label-per-address-ignores-banking.md) is related.

More decisions:
- **Includes** match the C64 set in depth: zero page, system RAM (`$0200-$1bff`), I/O with the MMU and VDC, the KERNAL and screen editor jump tables, and the BASIC 7.0 entry points, all checked against the ROM listing. The tws128 drafts are the starting point.
- **`--init`** treats a file as a C128 program only when asked, with an explicit option (e.g. `--init game.prg c128`); the default stays C64. Then it reads the BASIC stub at `$1c01` and suggests `include c128.flo`.
- **A `bank 1` run follows the MMU:** it reads the RAM configuration register (`$d506`) from the snapshot and loads the common area from bank 0 and the rest from bank 1, as the CPU sees it.
- **Test material:** a real x128 snapshot (for example of The Write Stuff 128 running), taken in VICE by the user and added to `tests/resources/`.

Done when an x128 snapshot loads (bank 0 by default, `bank 1` as an option), `include c128.flo` is built in, `--init` handles a `$1c01` PRG and an x128 snapshot, and `README.md` lists the C128 includes. Part of [0098](0098-keep-the-disassembler-generic.md).

## Progress

Done: x128 snapshots load (`C128MEM` 0.0, `MAINCPU` 1.3; x128's `VIC-II` 1.3 has another layout and isn't read), bank 0 by default, bank 1 following the MMU's shared RAM (`loaders.ram`). The `c128*.flo` built-ins, checked against VICE's ROMs (`kernal-318020-05`, `basiclo/hi-31801x-04`) and the snapshot's defaults. `--init` reads an x128 snapshot (always C128) and a `.prg`/`.bin` with `c128` last; `bank <n>` on `--init`, `--dump`, `--find` and `--strings`. Snippets: `init/c128_*`, `init/bank_on_*`, `dump/c128_bank1`, `large/c128_snap`, `short/include_c128`; resources `c128_snap/` (the user's snapshot of x128 at READY) and `c128_prg/`.

Bank 1 is chosen with 24-bit addresses, as the C128's monitor writes them: a snapshot's part `$10000-$20000` (on a `deflower` line and on the command line, which dropped its `bank` option). No `bank` keyword: banks mean different things on different machines.

## Closing note

All of it is done: x128 snapshots (bank 0 by default, bank 1 as `$10000-$20000`, following the MMU's shared RAM), the `c128*.flo` built-ins, and `--init` for x128 snapshots and, with `c128`, for C128 programs. Labels in other banks stay with [0139](0139-memory-in-other-banks.md), which can use the same 24-bit addresses.
