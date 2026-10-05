# Issues

Local issue tracker. The git remote is a local bare repo, so issues live in this directory, not on a hosted service.

- One issue per file: `NNNN-short-slug.md`, numbered in creation order.
- Each file starts with frontmatter:

  ```
  ---
  title: One-line summary
  status: open | in-progress | done
  labels: bug, enhancement, cleanup, test
  ---
  ```

- Body: what happens, where (file and line), and what done looks like.
- Update `status` in the file when work changes state. Close by setting `status: done`; don't delete files.
- The index below is the list of all issues. Keep it in sync when adding one.

## Index

| # | Status | Title |
|---|--------|-------|
| [0001](0001-squirm-snapshot-rejected.md) | open | `squirm.vsf` rejected as "Old VICE snapshot file" |
| [0002](0002-only-byte-data-emitted.md) | open | Output only emits `BYTE` data |
| [0003](0003-flo-comments-dropped.md) | open | `.flo` comments are parsed but not carried to the output |
| [0004](0004-tests-have-no-assertions.md) | open | Tests only smoke-run the pipeline |
| [0005](0005-debug-output-everywhere.md) | open | Excessive `System.out` tracing |
| [0006](0006-dead-parseline.md) | open | Unused legacy `parseLine` in `SubjectConfigurer` |
