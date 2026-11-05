---
title: Failed to parse VICE snapshot .flo file: unexpected '-' at line 14
status: open
priority: medium
labels: bug, parser
---

When processing a VICE snapshot `.flo` file, the parser fails with:

```
Failed to parse vice-snapshot-20261105081036.flo:
line 14: expected at, from, size or the end of the line, found '-'
```

The error occurs at line 14 of the `.flo` file when the parser encounters a `-` character.
Support `-` in a filename unless this breaks the grammar.
See if more common filename characters are not supported.