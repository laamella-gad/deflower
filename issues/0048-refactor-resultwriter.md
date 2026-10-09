---
title: Refactor ResultWriter - it is doing too much
status: open
labels: cleanup
---

`ResultWriter.java` is 590 lines with two classes. Most of it is `AssemblyFileFormat`, which has picked up a new concern with nearly every output issue (0027, 0029, 0039, 0040, 0046). It now mixes:

- **Low-level line/column state.** `newLine`, `indent`, `print`, `column`, `atLineStart`, `inQuotes`, `needsToReOrg` and `lastArea`. All of this is mutable state shared by every printing path, and several paths reach into each other's fields: for example, `newLine()` closes string quotes, and `printAnnotation` reads `column` to decide line breaks.
- **Layout policy.** Blank-line separators, label glueing and run continuation (`printAnnotation`, `isSingleValueRun`; issues 0027/0029), plus `*=` origins (`considerReOrg`).
- **Per-type value formatting.** `print(DataArea, ...)`'s switch, `tabularPrint`, and `textPrint` with quoting.
- **Text encoding analysis.** `encodingFor` with its per-array cache fields, `isElementOf` and `characterFor` (issue 0040). This is a heuristic over memory contents, not output formatting.
- **Virtual blocks.** `printVirtualStretch` and its own scanning helpers (`endOfVirtualRun`, `annotatedInside`, `firstAnnotatedAddressInside`, `reservationDirective`; issue 0046). It runs a separate address walk inside the main one, which returns the next address back to `write`'s loop.
- **Operand naming.** `printInstruction` with its addressing-mode switch, and `nameForAddress`.
- **Memory scanning, done several times.** "Does the run continue here?" is answered separately by `isSingleValueRun`, `endOfVirtualRun` and `isElementOf`, each with slightly different rules: label/comment breaks, type equality, virtual flag, array membership.
- **File-system work.** `ResultWriter` itself (`prepareOutputDirectory`, `recreateDirectory`, and opening the file) next to the address walk in `write`.

The result is that each new output feature needs to know which other paths touch `column`/`atLineStart`/`lastArea`, and adding one (e.g. `.null`/`.ptext`, issue 0047, or the lowercase opcodes of issue 0042) gets harder every time.

## Directions to consider

- Split the "emitter" (lines, columns, indentation, open quotes; one place that knows how to start and finish a line) from the "layout" (when to break, separate, glue or re-org).
- Move the memory analysis (run boundaries, array extents, the encoding heuristic) out of the printer into something that answers questions about `Subject`. It could live next to `Subject`/`DataArea`, or be a pass that runs before printing.
- Give each area kind its own printer (data/tabular, text, virtual block, instruction) behind a common shape. That also makes `write`'s loop and `printVirtualStretch`'s inner loop one mechanism instead of two.
- Move the output-directory handling out of `ResultWriter` (or into `Deflower`).
- The tangle with `lastArea` (set by some paths, reset to null by `printVirtualStretch`, compared by type in others) probably wants to become an explicit "previous output kind" state.

## Scope

Pure refactor: the generated output must not change. Every `expected.asm` must stay byte-identical (snipsert), and the 64tass reassembly of the small fixtures must still match their `.prg` bytes.

Done when: `AssemblyFileFormat` is split along lines like the above, no class mixes memory analysis with line/column state, and all tests pass with unchanged expectations.
