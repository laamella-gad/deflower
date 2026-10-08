---
title: Annotations are applied as side effects during the parse walk
status: open
labels: enhancement, cleanup
---

`SubjectConfigurer` applies each `.flo` line to `Subject` as the ANTLR walker visits it, instead of first building a list of directives and then applying them in a fixed order. That ordering dependency is the root cause of [0009](0009-annotation-before-deflower-npe.md) (annotation before `deflower` crashes) and [0010](0010-second-deflower-wipes-annotations.md) (a second `deflower` wipes earlier work).

Suggested shape: parse the `.flo` file into a list of directives (load image / mark data / mark code / label), then apply them in a fixed order: load image first, then annotations, then hand off to `FlowAnalyser`. This also makes `SubjectConfigurer`'s output testable without a `Subject`.

Done when: directive order in the `.flo` file no longer changes behaviour (loads always happen before marks), and 0009/0010 are resolved as part of this change.
