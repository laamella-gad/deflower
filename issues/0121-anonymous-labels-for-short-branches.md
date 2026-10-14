---
title: Use anonymous labels for short loops and skips
status: open
priority: low
labels: enhancement
---

Every branch target gets an auto label like `lC00A`, which tells the reader nothing. Short loops and skips, which are most branches, would read better with 64tass's anonymous labels: `-` and `bne -` for a loop back, `+` and `beq +` for a skip forward.

da65 has unnamed labels too ([0060](0060-investigate-da65-features.md)). [0091](0091-name-local-labels-by-role.md) is the other way to make auto labels tell more, and asks the same question about `-`/`+`.

mpu6502's `SourceParser`, which `Verifier` and the snippets' round trip assemble with, has no anonymous labels, so it needs them first. That is a change in the mpu6502 repository.

Open: when a label is anonymous (only branches use it, all of them within a few lines, no other label in between, no cross-reference that names it); `--` and `++` for a second level; and whether the `.map`, warnings and cross-references still need the `lXXXX` name.

Done when short branch targets print as `-`/`+` where that is unambiguous, and the output still reassembles.
