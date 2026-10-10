---
title: Log the CPU state, at least the PC, when reading a VICE snapshot
status: open
priority: low
labels: enhancement
---

A snapshot's program counter is the most reliable code entry point it has: whatever the CPU was executing is code. Every snapshot fixture (`1nvader_snap`, `2krace_snap`, `3dgolf_snap`, `3dgolfpic_snap`) starts with a `$xxxx code snapshot_pc` line. Deflower doesn't show the PC anywhere, so finding it meant parsing the `.vsf` by hand outside Deflower.

`ViceSnapshotReader.read` passes only a `C64MemModuleHandler` to `ViceVcfFileReader`, so every module except `C64MEM` ends up as an `UnhandledModule`, including `MAINCPU`. It prints the whole `ViceVcfFile`, but that doesn't decode the CPU registers.

The `MAINCPU` module (version 1.4 in the VICE 3.9 snapshots) starts with an 8-byte clock, then `A`, `X`, `Y`, `SP`, a 16-bit `PC` and the status register. In `3dgolfpic_snap.vsf`:

```
df4a151b00000000 40 00 00 f6 847f 21
clock            A  X  Y  SP PC   P
```

so PC = `$7f84`.

Want: when a snapshot is read, log the CPU state, e.g.

```
Snapshot CPU: PC=$7F84 A=$40 X=$00 Y=$00 SP=$F6 P=$21 ($01=$37)
```

The processor port from `C64MEM` (`$01`, which says which ROMs are banked in) belongs in the same line, because it decides how to read the PC's surroundings.

To do:
- a `ModuleHandler` for `MAINCPU` (check the layout against VICE's `maincpu_snapshot_write_module` for the module versions in the fixtures);
- a way to combine handlers, since `ViceVcfFileReader.read` takes one;
- the log line in `ViceSnapshotReader`.

Not part of this: using the PC automatically as a `code` entry point. That could come later as a `.flo` option, but it changes the output, so it needs its own decision.

Done when: running any snapshot fixture prints its PC (and the other registers) in the log, and the values match the `snapshot_pc` lines in the fixtures.
