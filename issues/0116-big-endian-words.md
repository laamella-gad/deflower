---
title: Add a data type for 16-bit values stored high byte first
status: open
priority: low
labels: enhancement
---

All of deflower's multi-byte types are little-endian, as the 6502 is. Programs still store some values high byte first: score counters printed digit by digit, tables built for `lda table, x` / `sta ptr + 1` order, and data copied from other machines. Such a value now has to be declared as two `.byte`s, and the reader works out the number by hand.

da65 has `DBYTETABLE` for this ([0060](0060-investigate-da65-features.md)). 64tass has no big-endian `.word`, so the output needs a form that reassembles, e.g. `.byte >$1234, <$1234`, or a small macro defined at the top of the output.

Open: the keyword (`bword`? `dbyte`?), whether it gets signed and 24/32-bit siblings, and whether an address variant (a big-endian `addr`) is needed for its target's label.

Done when a high-byte-first word can be declared, prints its value as one number, and the output reassembles to the same bytes.
