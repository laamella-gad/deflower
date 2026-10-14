---
title: Optionally print each line's address and bytes as a comment
status: open
priority: medium
labels: enhancement
---

The `.asm` shows labels, not addresses. To match a line against the VICE monitor, a `--dump`, a verify `differ` line or a warning, the reader has to count from the nearest label, or look the address up in the `.map` file.

da65's comment levels add the address and the bytes of each line as a comment, up to a text column at level 4 ([0060](0060-investigate-da65-features.md)). Deflower could do the same behind a flag, e.g. `--addresses`, or a line in the `.flo` file, so a watched output keeps it:

```
lC00A:
		lda table, x	; $c00a  bd 00 c1
```

Open: a flag or a `.flo` setting; whether data lines get it too (one address per line); and how it sits with the existing end-of-line comments (call parameters, `operand set by`).

Done when the output can show each instruction's address and bytes, and the snippets show both forms.
