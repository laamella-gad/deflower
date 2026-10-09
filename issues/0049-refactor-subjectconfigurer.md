---
title: Refactor SubjectConfigurer - it is doing too much
status: done
labels: cleanup
---

`SubjectConfigurer` turns a `.flo` file into `Subject`s, and does all of it in one method with an anonymous ANTLR listener. It mixes:

- **Parser setup.** Building the lexer/parser and collecting syntax errors (`createParser`).
- **Per-line parse state.** The listener's mutable fields (`address`, `addressEnd`, `type`, `amount`, `isVirtual`, `name`, `pendingComments`), reset by `startNewLine` and filled in by the `enter*` callbacks.
- **Applying a line to memory.** `exitLine` writes labels and comments into `Subject.memory`, registers `DataArea`s, and pushes code entry points, all from inside the parse walk.
- **Loading memory images.** `enterSetFileName` creates the `Subject` and reads a `.vsf` snapshot or a `.prg` (`readSnapshot`, `readPrgFile`, `supportedMachines`) in the middle of the walk.
- **Small helpers.** `parseNumber`, `commentText` and `outputFileNameFor`.

Parsing, loading files and changing memory all happen during one tree walk, so each concern can only be read, tested or changed together with the others.

## Decided design

- **Two phases.**
  - First, parse: the listener only turns each line into a plain value describing the annotation, grouped per `deflower` line.
  - Then, apply: for each group, create the `Subject`, load its image, and apply the annotations in order.
- **Applying** is a method on `Subject` (`annotate`), next to `registerBlock` and the label/code-location methods.
- **Image loading** goes to its own class.
- **`LineType`** stays as it is; it only moves out of `SubjectConfigurer`.

## Scope

Pure refactor:
- the generated output must not change, and every `expected.asm` must stay byte-identical (snipsert);
- the parse-error, missing-`deflower`-line and area-conflict behaviour must stay the same.

## Closing note

Done as decided. `SubjectConfigurer` is now only the two-phase driver, 40 lines long. For each run it creates the `Subject`, sets the output file name, loads the image, and applies the annotations.

- **`FloReader`** (parse phase): parser setup with syntax-error collection, and a named listener (`AnnotationCollector`) that keeps the per-line state and turns each line into an `Annotation`. The annotations are grouped into one `DeflowerRun` per `deflower` line. `parseNumber` and `commentText` moved here too. It reads only the `.flo` file and changes no memory. The "Failed to parse", "Start the file with a 'deflower <file>' line." and "Require an address" checks keep their messages.
- **`Annotation`** / **`DeflowerRun`**: plain immutable values. The code targets Java 14, so they are classes rather than records. A pending comment is joined into the annotation it belongs to.
- **`Subject.annotate(Annotation)`** (apply phase): sets the label and comment, pushes code entries, and registers data areas. The amount of a memory range is computed here, as before.
- **`ViceSnapshotReader`** (`.vsf`, with `supportedMachines`) and **`PrgReader`** (`.prg`) load the memory images. `SubjectConfigurer.loadMemoryImage` picks between them by file extension.
- **`LineType`**: moved to its own file, unchanged.

One change in ordering: memory images are now loaded after the whole `.flo` file is parsed, rather than during the walk. So a missing `deflower` line or a missing address fails before any image is read. Only the order of the console tracing changes. Errors and output stay the same.

Verification: 30/30 tests green. No `expected.asm` changed. screencodes, strings and datatypes still reassemble with 64tass to their `.prg` bytes. A `.flo` without a `deflower` line still prints "Start the file with a 'deflower <file>' line." and writes nothing.
