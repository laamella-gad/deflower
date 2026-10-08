---
title: Area conflicts are silently overwritten
status: open
labels: enhancement
---

`Subject.registerBlock` (`src/main/java/com/laamella/deflower/Subject.java`) replaces whatever `Area` was already at an address with no check and no warning. `FlowAnalyser` also calls it after confirming the address is free, but `SubjectConfigurer` does not. So a `.flo` file that marks a data block over code the tracer already found, or two overlapping data blocks, loses one silently.

For a semi-automatic tool this is the main feedback loop: the user needs to know when their annotation disagrees with what the tracer found, or with another annotation. Right now there is no signal either way.

Done when: `registerBlock` reports (at minimum logs, ideally fails loudly) when it overwrites an existing non-null `Area`, naming both areas and the address.

See also [0023](0023-instruction-partially-overlaps-later-area.md), a concrete case of this: a decoded instruction's own length carrying it into a later area mid-decode.
