---
title: Allow trailing comments on .flo lines
status: open
priority: low
labels: enhancement
---

A `;` or `#` comment in a `.flo` file must sit on its own line and attaches to the next annotation line. A comment after the annotation is a parse error:

```
$c000 code start ; entry point
```

Short notes next to the line they describe are the natural way to annotate, and the `.asm` output already uses trailing comments.

Done when:
- Any line (`deflower`, `load`, `include`, annotation, `{`, `}`) accepts a `;` or `#` comment after its last part, up to the end of the line.
- On an annotation line the trailing comment attaches to that line, like a comment line above it does. When both exist, decide how they combine (join, or the trailing one wins) and say so in `README.md`.
- Check that `#` inside a line is not mistaken for something else (`#<`/`#>` don't occur in `.flo` lines, but confirm in `src/deflower/flo/flo.ldb`).
- `src/deflower/flo/flo.ldb` changed and regenerated with `nimble flo`; `build` and `describe` in `flo_reader` follow; the grammar copy and the format section in `README.md`, and `src/deflower/help.txt`, are updated.
- Snippets in `tests/snippets/short/` cover a trailing comment on each kind of line, and one in `short/invalid/` if some placement stays an error.
