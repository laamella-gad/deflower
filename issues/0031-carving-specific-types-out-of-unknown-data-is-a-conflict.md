---
title: Carving a specific type out of a placeholder data block is reported as a conflict, blocking output
status: open
labels: bug
---

Issue 0018 made `Subject.registerBlock` report (and `Deflower.deflower` skip writing output over) any overwrite of a non-equal `Area`. But the normal, intended workflow for this semi-automatic tool is the opposite of "conflicts should never happen": mark a large range as `byte` (unknown data) first, then iteratively re-annotate smaller pieces of it with more specific types (`word`, `dword`, `char`, a sub-array, `code`) as they're understood. Every one of those re-annotations now overwrites a different, non-equal `Area` (a 1-byte `DataArea` at that address vs. the new 2-byte `word`, say), so 0018 flags it as an "Area conflict" and the whole subject's output is skipped - the main editing loop (run, read `out/deflowered.asm`, refine the `.flo`, run again) breaks on the very next save.

0018 was aimed at real disagreements (code vs. data, two incompatible declarations) and that part is still wanted. The mistake was treating "replace a placeholder with something more specific" the same as a genuine conflict.

Two designs to weigh:

1. **Only "unknown → specific" is allowed to overwrite silently; everything else is still a conflict.** Requires telling "this `byte` block is a real, deliberate byte array" apart from "this `byte` block is just a stand-in for not-yet-understood data" - which needs an actual `unknown`/placeholder `DataType` (output as `.BYTE`, same as today, but distinct from a deliberate `byte` annotation), since right now both are plain `DataType.BYTE` and indistinguishable at `registerBlock` time. Only an `unknown` area could ever be silently replaced; replacing a deliberate `byte`/`word`/`char`/`code` area (or being replaced by one) stays a reported conflict, same as today.

2. **Any area can overwrite any other area**, full stop - conflict reporting goes away entirely (or becomes a quieter log line, not something that blocks output), and the user is trusted to know they're narrowing an earlier annotation. Simpler, no new `DataType` needed, but loses the "catch a real mistake" signal 0018 was trying to add - e.g. accidentally re-annotating over code, or two overlapping deliberate declarations that actually disagree, would again go unnoticed.

Design (2) is simple but throws out 0018's actual value; design (1) keeps that value but needs the new `unknown` type to be meaningful, which also changes what "mark a block as byte" means in every `.flo` file today (currently the de facto placeholder) - worth deciding explicitly rather than leaving `byte` to silently keep double-duty as both "deliberate" and "placeholder".

Done when: a decision is made between (1) and (2) (or another shape), and `registerBlock`/`Deflower.deflower` is changed so that narrowing a placeholder/unknown block into more specific sub-annotations is the normal, silent (or at most informational) case, while a genuine disagreement between two deliberate annotations (or code vs. data) still reports and still blocks output as 0018 intended. Add a fixture covering the "mark big block byte, then carve out a word/char/code sub-range inside it" workflow as a regression test either way.
