# Issues

Local issue tracker. The git remote is a local bare repo, so issues live in this directory, not on a hosted service.

- One issue per file: `NNNN-short-slug.md`, numbered in creation order.
- Each file starts with frontmatter:

  ```
  ---
  title: One-line summary
  status: open | in-progress | done | invalid
  labels: bug, enhancement, cleanup, test
  ---
  ```

- Body: what happens, where (file and line), and what done looks like.
- Update `status` in the file when work changes state. Close by setting `status: done`; don't delete files.
- The index below is the list of all issues. Keep it in sync when adding one.

## Index

| # | Status | Title |
|---|--------|-------|
| [0001](0001-squirm-snapshot-rejected.md) | done | `squirm.vsf` rejected as "Old VICE snapshot file" |
| [0002](0002-only-byte-data-emitted.md) | open | Output only emits `BYTE` data |
| [0003](0003-flo-comments-dropped.md) | open | `.flo` comments are parsed but not carried to the output |
| [0004](0004-tests-have-no-assertions.md) | done | Tests only smoke-run the pipeline |
| [0005](0005-debug-output-everywhere.md) | done | Excessive `System.out` tracing |
| [0006](0006-dead-parseline.md) | done | Unused legacy `parseLine` in `SubjectConfigurer` |
| [0007](0007-range-end-off-by-one.md) | invalid | Address range end is off by one |
| [0008](0008-mul-ignores-datatype.md) | done | `n*m` size ignores the datatype |
| [0009](0009-annotation-before-deflower-npe.md) | done | Annotations before the deflower line throw NullPointerException |
| [0010](0010-second-deflower-wipes-annotations.md) | done | A second deflower line wipes earlier annotations |
| [0011](0011-indirect-jmp-followed-as-absolute.md) | done | `JMP (indirect)` is followed as if it were absolute |
| [0012](0012-printing-bounds-off-by-one.md) | done | Printing bounds checks admit out-of-range values |
| [0013](0013-asHexDword-always-throws.md) | done | `asHexDword` always throws |
| [0014](0014-storeAt-no-bounds-check.md) | open | `storeAt` does not check bounds |
| [0015](0015-lda-labelling-only-absolute.md) | open | LDA labels data only for absolute addressing |
| [0016](0016-duplicate-path-resolution.md) | done | Snapshot path is resolved twice |
| [0017](0017-annotations-applied-as-side-effects-during-parse.md) | open | Annotations are applied as side effects during the parse walk |
| [0018](0018-area-conflicts-silently-overwritten.md) | open | Area conflicts are silently overwritten |
| [0019](0019-ship-as-single-executable.md) | open | Project should ship as a single executable, not a Java jar |
| [0020](0020-pretty-data-formats.md) | open | Add pretty disassembly formats for known data shapes (charset, screen, sprite) |
| [0021](0021-parse-errors-not-collected.md) | done | Parse errors are printed to stderr and ignored, not collected and failed on |
| [0022](0022-export-region-to-binary.md) | open | Mark regions for export to a binary file, included from the generated asm |
