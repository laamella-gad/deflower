---
title: Break data lines by the shape of the array
status: open
priority: low
labels: enhancement
---

`ResultWriter` prints data 16 values to a line, whatever the array holds. A screen of `byte[40*25]` would read better as 25 lines of 40, a sprite as 21 rows of 3 bytes, and a table of 5-byte records as one record per line.

da65's `RANGE` has `UNIT` for this: a line break at every group of N bytes ([0060](0060-investigate-da65-features.md)). Deflower already has the shape in many `.flo` lines: the first factor of a size like `byte[40*21]` could be the line width. That needs a decision: using the size's factors changes the output of existing files, so maybe only an explicit marker should, e.g. `byte[21 rows 3]`.

Related: [0020](0020-pretty-data-formats.md) (dedicated formats for charsets, screens and sprites) and [0110](0110-parallel-arrays.md).

Done when an array can be printed with a chosen number of elements per line, documented in `README.md`.
