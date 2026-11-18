---
title: Disassemble C128 programs: snapshots, includes and --init
status: open
priority: medium
labels: enhancement
---

Found disassembling The Write Stuff 128 v1.83 (`~/dev/c64-productivity/tws128`), a C128 word processor in three PRGs (`bb writer` at `$1c01`, `bb1` at `$2500`, `bb2` at `$3820`). Deflower traces the code fine from the PRGs, but nothing around it knows the C128:

- **Snapshots.** `loaders.nim:75` looks for the `C64MEM` module and fails with `No C64MEM found.` on an x128 snapshot. An x128 `.vsf` holds `C128MEM` with two 64K RAM banks plus the MMU registers. Taking a snapshot after the program has set itself up would give the relocated helpers at `$0111`, `$0200-$02a0` and the KERNAL's RAM routines for free, which the PRGs don't have.
- **Includes.** There are only `c64*.flo` built-ins. The project wrote its own `c128.flo`, `c128_io.flo` (VIC-IIe, SID, MMU `$d500-$d50b`, VDC `$d600/$d601`, CIAs, `$ff00-$ff04`), `c128_kernal.flo` (the editor jump table at `$c000-$c02d`, the KERNAL jump table `$ff47-$fff3` with `jsrfar`, `indfet`, `primm`, ...) and `c128_zeropage.flo`. These can become built-ins once checked against the ROM listing.
- **`--init`.** For a `.prg` at `$1c01` (C128 BASIC start) it should read the BASIC stub's `SYS` as on the C64 (`bb writer` has `SYS 7250`, `$1c52`), and offer `include c128.flo`.

Decided: all of it is wanted (includes, `--init` for `$1c01` PRGs, x128 snapshots), plus the bank label design of [0139](0139-memory-in-other-banks.md). A snapshot run takes bank 0; `deflower game.vsf bank 1` takes bank 1 as a run of its own. [0069](0069-one-label-per-address-ignores-banking.md) is related.

Done when an x128 snapshot loads (bank 0 by default, `bank 1` as an option), `include c128.flo` is built in, `--init` handles a `$1c01` PRG and an x128 snapshot, and `README.md` lists the C128 includes. Part of [0098](0098-keep-the-disassembler-generic.md).
