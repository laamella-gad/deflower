---
title: Annotations are applied as side effects during the parse walk
status: done
labels: enhancement, cleanup
---

`SubjectConfigurer` applies each `.flo` line to `Subject` as the ANTLR walker visits it, instead of first building a list of directives and then applying them in a fixed order. That ordering dependency is the root cause of [0009](0009-annotation-before-deflower-npe.md) (annotation before `deflower` crashes) and [0010](0010-second-deflower-wipes-annotations.md) (a second `deflower` wipes earlier work).

Suggested shape: parse the `.flo` file into a list of directives (load image / mark data / mark code / label), then apply them in a fixed order: load image first, then annotations, then hand off to `FlowAnalyser`. This also makes `SubjectConfigurer`'s output testable without a `Subject`.

Done when: directive order in the `.flo` file no longer changes behaviour (loads always happen before marks), and 0009/0010 are resolved as part of this change.

## Closing note

Already resolved by [0049](0049-refactor-subjectconfigurer.md), which split configuration into the two phases suggested here:

- **Parse:** `FloReader` turns the whole `.flo` file into `DeflowerRun`s holding plain `Annotation` values. It touches no `Subject` and loads no memory, so its output can be tested without a `Subject`.
- **Apply:** `SubjectConfigurer` then, per run, loads the image first, applies the annotations, and hands the subject to `FlowAnalyser`.

0009 and 0010 were already done. An annotation line before the first `deflower` line now fails during parse, before any image is read, with "Start the file with a 'deflower <file>' line.". Each `deflower` line starts its own independent run.

Added `DeflowerTest#rejectsAnnotationBeforeDeflowerLine` (fixture `invalid/annotation-before-deflower.flo`, whose binary doesn't even exist) as the regression guard. 41/41 tests green, no `expected.asm` changed.

Order still matters within one run, on purpose: a placeholder line (no type) may only be narrowed by a *later* line (see the Flo.g4 header). On the same address, a later label replaces an earlier one.
