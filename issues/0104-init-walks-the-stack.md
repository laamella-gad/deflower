---
title: --init reads only the top of the stack, not the frames below it
status: open
priority: medium
labels: enhancement
---

For a snapshot, `Initializer.stack` prints the stack bytes and reads the top as a `jsr` return address and as an interrupt's return address. For `bigmac.vsf` that gives:

```
; stack $01ec-$0200: 02 00 fa 7f 21 68 67 ae 4a 0e 4b 46 e1 e9 a7 a7 ...
; top of stack as a jsr return address: $0003
; top of stack as an interrupt's return address: $fa00
```

Both are wrong. The snapshot was taken inside the IRQ handler at `$c543`, which did a `pha` after the KERNAL's IRQ entry at `$ff48` pushed A, X and Y on top of the CPU's P and PC. Reading the stack by hand gives the main code that was interrupted, and the `jsr` chain under it:

- `$02`: the handler's `pha`;
- `$00 $fa $7f`: Y, X, A pushed by `$ff48`;
- `$21`: P, `$6768`: the interrupted PC, inside `read_input` (`$6750`);
- `$4aae`: a `jsr` return address, so code at `$4aaf` (after the `jsr` at `$4aac`);
- `$4b0e`: another, so code at `$4b0f`;
- then `$e146`, `$a7e9`, ...: BASIC's frames under the program's `SYS`.

These were the entries that got the main loop traced; without them most of the game was unreached.

Want: `--init` walks the stack and writes the frames it can explain, with a `code` line for each RAM return address:
- An interrupt frame: if the IRQ vector at `$0314` is used, the KERNAL's `$ff48` pushed A, X, Y over P and PC, and the handler's code up to the snapshot PC tells how many more bytes it pushed (`pha`, `php`, `jsr`), as far as a plain trace can say.
- Then each pair of bytes whose value plus one follows a `jsr` (the byte three before it is `$20`, and its operand is the routine the frame above was in, when known) is a return address.
- Stop at the first pair that doesn't fit, and print the rest as bytes, as now.

The comments say which frame each value comes from, and the guessed ones are marked as guesses: `$4aaf code return_4aaf` with `; returned to from $4aac jsr $67a0`.

Done when: `bigmac`'s skeleton has code lines for `$6768` (or its routine), `$4aaf` and `$4b0f`, no `$0003`/`$fa00`, and the other snapshots' skeletons don't gain wrong entries.
