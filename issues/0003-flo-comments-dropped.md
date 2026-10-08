---
title: .flo comments are parsed but not carried to the output
status: done
labels: enhancement
---

`Flo.g4` defines `COMMENT` (`;` or `#`) and a `comment` statement, and has a `// TODO add comments to disassembly` note. `SubjectConfigurer` does not override `enterComment`, so comments are dropped.

Done when: comments from the `.flo` file appear in `deflowered.asm` next to the addresses they annotate. ✅

Fixed: the grammar only allows a comment as its own standalone statement line (not inline trailing a `$addr ...` annotation), so that's what's supported — one or more consecutive comment lines attach to the address of the next annotation line. `SubjectConfigurer`'s listener now has `enterComment` (strips the `;`/`#` marker and one following space, appends to a `pendingComments` list) and attaches that list, joined with `\n`, to `subject.memory[address].comment` in `exitLine`, clearing it afterwards. `pendingComments` is also cleared in `enterSetFileName` so a dangling comment can't leak into the next `deflower` line's subject. `MemoryLocation` got a new `comment` field alongside `label`.

`ResultWriter`'s per-address loop used to call `printLabel` only when a label was present; it now calls a combined `printAnnotation(address, comment, label)` whenever either is present, printing each comment line as `; ...` above the label (both share one blank-line separator, so there's no extra blank line wedged between a comment and the label it documents).

New fixture `comments/` covers a lone single-line comment on a data byte and a two-line comment on a code entry. The existing `squirm` fixture's `.flo` already had real `; .../# ???` comments that were silently dropped before; `expected.asm` was regenerated and reviewed — the only change is those comment lines now appearing where they belong.
