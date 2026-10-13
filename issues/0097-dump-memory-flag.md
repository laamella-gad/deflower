---
title: A command line flag that hex-dumps a memory range of an input file
status: open
priority: medium
labels: enhancement
---

Writing a `.flo` file means looking at raw bytes all the time: is this a BASIC stub, code, a table, VICE's power-on pattern? Deflower can't show them, so a throwaway Python script that finds the `C64MEM` module in a `.vsf` file and hex-dumps a range got written yet again while filling the gaps in `1nvader_snap` and `2krace_snap`. It found the decruncher at `$080d`/`$0100`, its leftover source at `$15e9`, and the power-on pattern around them.

Want: `deflower --dump <file> <start>-<end>`, reading a `.vsf` or `.prg` like a `deflower` line does, and printing the range as hex with an ASCII column, 16 bytes a line:

```
c540: c0 58 60 20 8d c4 ad cf c0 f0 1b 4a 48 90 06 20  .X` .......JH..
```

The range is written as in a `.flo` file (`$c540-$c560`, end exclusive), so a `gap` line from `--verify` can be pasted. Memory the image doesn't load is shown as `..`, not as zeros. No `.flo` file is needed and nothing is written.

Related:
- [0072](0072-inspect-input-file.md) (`--inspect`) lists the facts of interest in an input file; `--dump` shows the bytes. They share the input reading, and the same decision on whether the path is classpath-relative or a file system path.
- [0080](0080-show-memory-as-screen-text-and-glyphs.md) shows memory as screen text, glyphs or sprites; a later step on top of this one.

Maybe later, not part of this: marking the bytes that still hold VICE's power-on pattern (which needs the tolerant match 0072 describes), and a disassembly view of the range.

Done when: the flag dumps a range of a `.vsf` and of a `.prg` fixture, unloaded memory shows as `..`, and the flag is described in `CLAUDE.md`.
