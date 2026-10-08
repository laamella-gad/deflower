---
title: Area conflicts are silently overwritten
status: done
labels: enhancement
---

`Subject.registerBlock` (`src/main/java/com/laamella/deflower/Subject.java`) replaces whatever `Area` was already at an address with no check and no warning. `FlowAnalyser` also calls it after confirming the address is free, but `SubjectConfigurer` does not. So a `.flo` file that marks a data block over code the tracer already found, or two overlapping data blocks, loses one silently.

For a semi-automatic tool this is the main feedback loop: the user needs to know when their annotation disagrees with what the tracer found, or with another annotation. Right now there is no signal either way.

Done when: `registerBlock` reports (at minimum logs, ideally fails loudly) when it overwrites an existing non-null `Area`, naming both areas and the address. ✅ (logs; chose not to fail loudly — see note below)

See also [0023](0023-instruction-partially-overlaps-later-area.md), a concrete case of this: a decoded instruction's own length carrying it into a later area mid-decode. This fix makes that case visible (it now logs) but doesn't make 0023 done — 0023 also wants the overwritten area to survive untouched, which logging alone doesn't give it.

Fixed: `registerBlock` now appends `Area conflict at <addr>: <new area> overwrites <existing area>` to `Subject.errors` whenever it's about to overwrite a different, non-null `Area`. "Different" is judged by a real `equals()`/`hashCode()` on `Area` (address, size, and `getClass()`), extended by `DataArea` (adds `type`, `isSystem`) and `InstructionArea` (adds the `Instruction`) — not `toString()`, which stays purely for the human-readable message (`InstructionArea` was given one, naming its opcode). A redundant re-annotation that agrees with what's already there (`equals()` true) isn't reported — only genuine disagreements are. Running the full existing test suite with unconditional logging (no filter) showed hundreds of same-content re-registrations in the real fixtures (squirm/zwark/tcmine), confirming the filter is needed and correctly silences them while still catching real conflicts.

`Subject.errors` (a plain `List<String>`) is the general collection point for this kind of problem, not a one-off boolean flag — `Deflower.deflower` is the one that decides what to do with it: after analysing each subject, it checks `subject.errors`, prints every entry plus a skip notice to stderr, and does not call `ResultWriter.write` for that subject — a conflict means the generated asm would be illegal (two areas disagreeing on the same bytes), so it's better not written at all than written wrong. `Subject` itself never prints; it only collects.

New `overlap` fixture + `DeflowerTest#reportsAreaConflictAndSkipsOutputOnOverlap` (a `word` then an overlapping `byte` inside it — genuine conflict: must report on stderr, must not write `overlap.asm`) and `DeflowerTest#doesNotLogIdenticalReRegistration` (the `datatypes` fixture — no conflicts, must stay silent and write normally).
