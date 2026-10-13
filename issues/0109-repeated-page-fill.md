---
title: Recognise memory filled with one repeated page
status: open
priority: low
labels: enhancement
---

`bigmac.vsf` has `$c900-$d000` filled with the same 256 bytes seven times over, and the same page again at `$6000`. The page is a stretch of the KERNAL around `$fd00` (reset, the `CBM80` check, the vector table), copied there by whatever ran before the game. It is neither VICE's power-on pattern nor zeroes, so `--init` doesn't mark it, and it took a long dump to see it repeats.

`--init` could mark a run where each page (or some other period up to 256 bytes) equals the one before it, as it marks the power-on pattern:

```
$c900-$d000 virtual byte fill_c900
; $c900-$d000: the page at $c900 repeated 7 times
```

Whether it should be `virtual` is less clear than for untouched memory: the bytes are the program's memory and someone might read them. A plain `byte` line, or only the comment, may be better.

The same check would help `--dump` (collapse repeated lines, like `hexdump`'s `*`), so the long dumps of these areas get short.

Related: [0081](0081-flag-unreferenced-code-and-leftovers.md) (padding: runs of one byte), [0103](0103-init-marks-used-memory-untouched.md).

Done when: `bigmac`'s skeleton names `$c900-$d000` as a repeated page, and no other fixture gets a false one.
