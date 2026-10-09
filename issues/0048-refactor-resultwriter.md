---
title: Refactor ResultWriter - it is doing too much
status: done
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

## Closing note

Done at moderate scope, as decided up front: the emitter and the memory analysis came out; `AssemblyFileFormat` keeps layout and per-type printing. Three steps, with the full suite, unchanged expectations and the 64tass reassembly check after each:

1. **File-system work moved to `Deflower`.** `prepareOutputDirectory`/`recreateDirectory` and opening the `.asm` file live there now; `ResultWriter.write(Subject, Writer)` only walks memory.
2. **Memory analysis moved to `Subject`/`DataArea`.**
   - `Subject`: `isVirtualAt`, `isAnnotated`, `firstAnnotatedAddressInside`, `continuesRun`, `endOfRun`, `endOfArray` and `likelyTextEncoding` (the uppercase-letter heuristic, with the tie answer passed in).
   - `DataArea`: `arrayStart` and `isInSameArray`.
   - The two "does the run continue here?" checks (`isSingleValueRun`, `endOfVirtualRun`) are now one rule, `Subject.continuesRun`: an element of the same type and the same virtual flag starts there, and no label or comment interrupts the run. The behaviour is identical: annotations only see non-virtual blocks, and virtual runs only see virtual ones.
   - `AssemblyFileFormat` keeps only the per-array cache of the encoding decision, because a tie depends on the encoding in effect in the output.
3. **New emitter class, `LineEmitter`.** It holds the writer, line start, value column and open quotes, with `print`, `newLine`, `finishLine`, `indent`, `item` (comma separators) and `quotedCharacter`. `AssemblyFileFormat` no longer touches `atLineStart`/`inQuotes`, and it reads `column` only through `column()`. `printAnnotation` reuses `printCommentLines`.

Not done (out of the chosen scope):
- per-kind printers behind a common shape, which would merge `write`'s loop with `printVirtualStretch`'s;
- an explicit "previous output kind" in place of `lastArea`;
- a `TextEncoding` type in place of the `"none"`/`"screen"` strings.

Verification: 30/30 tests green. No `expected.asm` changed. screencodes, strings and datatypes still reassemble with 64tass to their `.prg` bytes.
