---
title: Report how much of a disassembly is code, typed data and plain bytes
status: open
priority: low
labels: enhancement
---

`bigmac` from scratch verified with 0 differ and 0 gaps, the "done" of `CLAUDE.md`. Most of the 41371 bytes emitted are plain `byte` lines that only close the gaps: the level data, the music data, the copies at `$7000`, the loader leftovers. "0 gaps" doesn't tell that apart from a disassembly where every table is understood.

Want: the verify report, or the map, gives a breakdown:

```
Verify out/bigmac.asm: 41371 bytes emitted, 0 differ, 24165 virtual, 0 gaps
  code 9870, text 412, typed data 6240, plain byte 24849, auto labels 312
```

- **Code**: bytes in decoded instructions.
- **Text**: `screencode`/`ascii` areas.
- **Typed data**: arrays of a declared type and size other than a bare `byte` range: `byte[40]`, `word`, `addr`, ...
- **Plain byte**: `byte` ranges with no size, and `UNKNOWN` placeholders.
- **Auto labels**: what [0090](0090-report-auto-labels.md) asks for.

Plain byte ranges that something references are the ones to look at next; the map could list them in order of size, or of references.

Done when: `--verify` prints the breakdown, covered by the snippets' verify lines, and `CLAUDE.md` explains it.
