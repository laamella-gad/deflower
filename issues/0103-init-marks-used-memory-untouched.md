---
title: --init marks memory the program uses as untouched or unused
status: done
labels: bug
---

The `untouched_xxxx` and `unused_xxxx` ranges `--init` writes for `bigmac.vsf` cover memory the program uses. They are `virtual`, so nothing in them is printed or verified, and a wrong one hides data without any warning: the verify report counts it as covered.

Found while disassembling `bigmac` from scratch:
- **Sparse sprite data**: `$32ac-$32f9`, `$3400-$3521`, `$36c0-$373f` and `$3780-$387f` are multicolor sprites (`$28`, `$aa`, `$3c`, `$c3` among many zeroes) inside the sprite block `$2b00-$3880`. `Initializer.powerOnPattern` lets a run continue over a byte that is not in the pattern once the run is 32 bytes long ("a byte with more than one bit flipped"), so a sprite that is mostly zero reads as the pattern.
- **Arrays that hold zeroes**: `$0974-$0a02` holds twelve 10-byte sprite tables (`$097e-$09f6`, cleared by `$3c5d` and used by dozens of instructions), and its last two bytes are the first instruction of the code at `$0a00`. In an earlier step the zero-valued column arrays at `$0924` and `$094c` were inside a range too.
- **Buffers**: `unused_b217` (`$b217-$b800`) is written by `$c309` and `$c3df`, and `unused_ba17` is read by `$c600` and written by `$c5e0`. They are the music player's buffers.
- **Range edges**: `untouched_0eff` started on the "d" of "keyboard" in the screen code text at `$0ec0`, a `$04`, one bit off from `$00`.

`--init` only sees the bytes, so it can't avoid all of these, but it can be more careful, and the run afterwards knows more:
- Don't let a run continue over bytes with several bits set; end it there instead (`$28`, `$aa`).
- Trim a range back to the bytes that are exactly `$00`/`$ff` at both ends, so it doesn't eat a neighbouring byte that only happens to be one bit off.
- **Warn on use.** After the trace, a virtual range named `untouched_`/`unused_` (or any virtual range from the skeleton) that an instruction reads or writes gets a warning naming the instructions: `warning: $0974: untouched_0974 is used by $3c60, $3c0f, ...`. The cross-references are already collected (`CrossReferences`); in the bigmac `.asm` they show up as `read by:`/`written by:` above the virtual block, but nothing says that is suspect.

Done when: a fresh `bigmac` skeleton has no untouched range inside `$2b00-$3880` or at `$0eff`, and a run on a `.flo` file with a skeleton range the code uses warns about it.

## Closing note

`Initializer.powerOnPattern` no longer lets a run continue over a byte with several bits set, except a lone byte between two exact `$00`/`$ff` once the run is 64 bytes long: VICE sets those at random, and they split long runs in `1nvader`, `3dgolf`, `bigmac` and `zwark` into pieces. A range is trimmed to exact `$00`/`$ff` at both ends, and a run that doesn't hold at least 1/8 of both `$00` and `$ff` (`MIN_SHARE`) only gives its zero stretches of 64 bytes or more as `unused`, which keeps sparse sprites out (also the invader shapes at `$3205-$32d4` in `1nvader`). A fresh `bigmac` skeleton has nothing inside `$2b00-$3880` or at `$0eff`.

After the trace, `Subject.warnUsedSkeletonRanges` warns about each `untouched_`/`unused_` virtual range of the `.flo` file's own that an instruction's operand names, listing the instructions (`short/skeletonrangeused.txt`). Targets with an included label are skipped, so KERNAL calls into a range under the ROM don't warn. On a fresh `bigmac` skeleton it points at the music player's buffers (`unused_9a52`, `unused_b217`, `unused_e252`); the finished `bigmac.flo` still has two such ranges, which the warnings in `large/bigmac.txt` show.

The arrays of zeroes (`$0974-$0a02`) can't be told apart from unused memory by the bytes alone; the warning is what catches them.
