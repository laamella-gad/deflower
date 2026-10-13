---
title: --strings finds many false strings in data separated by zeroes
status: open
priority: low
labels: enhancement
---

`--strings bigmac.vsf '$4d85-$66a0'` lists dozens of candidates in the level data:

```
$4e23 screencode[until $00]  "rdavdav"
$4e2b screencode[until $00]  "hdbfdbf"
$4e3d screencode[until $00]  "da da£bia"
$4e47 screencode[until $00]  "aet'gagp%gd"
...
```

The data is small numbers (`$01`-`$1a` are letters as screen codes) separated by `$00`, so nearly every record ends in a terminator and reads as a short word. The filters (6 letters, half different, one case) don't catch it, because the screen codes for small numbers are exactly the lowercase letters.

Ideas:
- **Words.** Real text has spaces between words of a few letters, and vowels; `rdavdav` and `hdbfdbf` have neither. A stretch of 6 or more letters without a space or a vowel is unlikely.
- **Density.** When most of a range comes out as candidates, it is data; report the range once (`$4e1f-$5d00: mostly small values, likely not text`) instead of each candidate.
- **Repeats.** `davdav`, `dbfdbf`: repeating short patterns are data.

Done when: `--strings` on `bigmac`'s `$4d85-$66a0` lists no candidates there, while the real texts (`$0ec0`, `$1026`, `$6810`, `$6875`) still show up on a run over the whole file.
