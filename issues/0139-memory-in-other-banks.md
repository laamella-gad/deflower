---
title: Name memory in other RAM banks (C128 MMU)
status: open
priority: low
labels: enhancement, research
---

[0069](0069-one-label-per-address-ignores-banking.md) is about the C64's `$01` port: one address, I/O or character ROM. The C128 makes that much bigger. The MMU (`$ff00`, `$d500`) chooses between two RAM banks and the ROMs, per 16K, and the program switches all the time.

Found in The Write Stuff 128 (`~/dev/c64-productivity/tws128`):
- `$c000-$feff` in bank 0 is the program's buffer, but with the usual configuration `$0e` the same addresses are the screen editor and KERNAL ROM. Code writes `$00` to `$ff00` (all RAM) around buffer accesses and `$0e` back after (`$251f`).
- The text being edited lives in bank 1 (`$0400` up), reached only through the helpers at `$0232-$0259` with a zero page pointer, so its addresses never show in an operand.
- `bb macros` and the help screens load into bank 1.

Want to find out: whether a label can carry a bank (`bank1:$0400 text_start`, or a `bank` block), how the configuration is known at a given instruction (stores of constants to `$ff00` and `$ff01-$ff04` in the same routine, or a `config $0e` annotation on a routine), and how an x128 snapshot's two banks become runs ([0132](0132-c128-support.md)). A design note is enough to start; implementing it can wait until 0069 has a form.
