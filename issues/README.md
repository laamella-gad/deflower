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
| [0002](0002-only-byte-data-emitted.md) | done | Output only emits `BYTE` data |
| [0003](0003-flo-comments-dropped.md) | done | `.flo` comments are parsed but not carried to the output |
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
| [0014](0014-storeAt-no-bounds-check.md) | done | `storeAt` does not check bounds |
| [0015](0015-lda-labelling-only-absolute.md) | done | LDA labels data only for absolute addressing |
| [0016](0016-duplicate-path-resolution.md) | done | Snapshot path is resolved twice |
| [0017](0017-annotations-applied-as-side-effects-during-parse.md) | done | Annotations are applied as side effects during the parse walk |
| [0018](0018-area-conflicts-silently-overwritten.md) | done | Area conflicts are silently overwritten |
| [0019](0019-ship-as-single-executable.md) | open | Project should ship as a single executable, not a Java jar |
| [0020](0020-pretty-data-formats.md) | open | Add pretty disassembly formats for known data shapes (charset, screen, sprite) |
| [0021](0021-parse-errors-not-collected.md) | done | Parse errors are printed to stderr and ignored, not collected and failed on |
| [0022](0022-export-region-to-binary.md) | open | Mark regions for export to a binary file, included from the generated asm |
| [0023](0023-instruction-partially-overlaps-later-area.md) | done | A decoded instruction partially overlapping a later area corrupts it |
| [0024](0024-no-label-plus-offset-for-access-inside-block.md) | done | No "label + offset" for an access that lands inside a larger labeled block |
| [0025](0025-adopt-assertj.md) | done | Adopt AssertJ to clean up ugly asserts |
| [0026](0026-array-as-one-area-not-one-per-element.md) | rejected | Model an array annotation as one Area, not one per element |
| [0027](0027-label-mid-block-fragments-byte-output.md) | done | A label in the middle of a data block breaks up its .BYTE output |
| [0028](0028-mid-block-labels-as-address-defines.md) | done | Emit a label inside a larger area as an address define, not inline |
| [0029](0029-first-label-in-run-still-glued.md) | done | First label of a run still glues onto its .BYTE line, inconsistent with the rest of the run |
| [0030](0030-ai-friendliness-of-flo-grammar.md) | done | Investigate whether the .flo format/grammar is easy to use, including for an AI writing it |
| [0031](0031-carving-specific-types-out-of-unknown-data-is-a-conflict.md) | done | Carving a specific type out of a placeholder data block is reported as a conflict, blocking output |
| [0032](0032-modernize-squirm-flo.md) | done | squirm.flo was written for an older version of deflower and needs modernizing |
| [0033](0033-array-elements-carry-own-label-reference.md) | done | Follow-up to 0026 - give each array element its own label reference instead of scanning for one |
| [0034](0034-support-hi-lo-byte-extraction-operators.md) | open | Support tass64's `<`/`>` hi/lo byte extraction operators in output |
| [0035](0035-implement-offset-block-syntax.md) | open | Implement the `{ }` block syntax as address-offset scoping |
| [0036](0036-use-tass64-addr-directive.md) | done | Use 64tass's `.addr` directive instead of `.WORD` for pointer values |
| [0037](0037-signed-numeric-datatype.md) | open | Add a signed numeric DataType (64tass's `.char`/`.sint`/`.lint`/`.dint`) |
| [0038](0038-rta-return-address-table-detection.md) | open | Detect and support 64tass's `.rta` return-address-table idiom |
| [0039](0039-text-string-directive-detection.md) | done | Detect runs of printable characters and emit 64tass's `.text`/`.null`/`.ptext` |
| [0040](0040-text-encoding-screen-code-vs-ascii.md) | done | Support 64tass text encodings (`.enc`/screen code) for CHAR output |
| [0041](0041-user-declarable-address-pointer-type.md) | open | Allow annotating a `.flo` line with type `address`/`pointer` |
| [0042](0042-lowercase-generated-assembly.md) | open | Generate lowercase assembly output (except user labels/comments) |
| [0043](0043-error-on-duplicate-label-definition.md) | done | Report an error when the same label is defined at two addresses |
| [0044](0044-array-size-arithmetic-and-hex.md) | done | Allow hex values and `*`/`+` arithmetic inside `[n]` array sizes |
| [0045](0045-system-keyword-ignored.md) | done | The `system` keyword is parsed but ignored, so system areas are dumped as data |
| [0046](0046-rename-system-to-virtual.md) | done | Rename `system` to `virtual` and emit 64tass `.virtual` blocks instead of address defines |
| [0047](0047-null-and-ptext-string-directives.md) | open | Emit `.null`/`.ptext` for null-terminated and length-prefixed strings |
| [0048](0048-refactor-resultwriter.md) | done | Refactor ResultWriter - it is doing too much |
| [0049](0049-refactor-subjectconfigurer.md) | done | Refactor SubjectConfigurer - it is doing too much |
| [0050](0050-fixed-flo-line-shape.md) | done | Give .flo annotation lines a fixed shape in the grammar |
| [0051](0051-document-flo-format.md) | done | Document the .flo line shape and keywords authoritatively |
| [0052](0052-auto-labels-are-64tass-local-labels.md) | done | Auto-generated labels start with `_`, which makes them 64tass local labels |
| [0053](0053-force-absolute-operand-on-zero-page-label.md) | open | Absolute operand on a zero-page label reassembles as zero page |
| [0054](0054-empty-labels-on-uncovered-memory.md) | done | Labels on memory no area covers come out as empty origin blocks |
| [0055](0055-placeholder-blocks-code-entry.md) | done | A jump target inside a placeholder is never traced |
| [0056](0056-help-flag.md) | open | Support a --help flag |
| [0057](0057-watch-mode.md) | open | Add a flag to run deflower as a live server that re-runs on file changes |
| [0058](0058-disassemble-region-to-separate-asm-file.md) | open | Disassemble a region into a separate .asm file, included from the main one |
