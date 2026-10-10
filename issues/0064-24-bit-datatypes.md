---
title: Support 24-bit datatypes (64tass's `.long`/`.lint`)
status: open
priority: low
labels: enhancement
---

Split out of [0037](0037-signed-numeric-datatype.md), which added signed 8-, 16- and 32-bit types but left out 24-bit because no fixture needed a 3-byte type.

64tass ("Storing numeric values") has two 24-bit directives:
- `.long` - 24-bit unsigned (0-16777215);
- `.lint` - 24-bit signed (-8388608-8388607).

Deflower's `DataType` has 1-, 2- and 4-byte types only. A 3-byte value (e.g. a 24-bit score or a BCD counter kept in three bytes, or a 65816-style long address) has to be declared as three bytes, or a byte plus a word.

Want: two new `.flo` types, printed with the value read little-endian from three bytes:
- an unsigned 24-bit type, printed as `.long $123456`;
- a signed 24-bit type, printed as `.lint -3`;
- reserved as `.long ?`/`.lint ?` in a `.virtual` block.

Scope: `Flo.g4` (tokens, `datatype`, format comment, reserved words), `FloReader`, `LineType`, `DataType` (size 3), `Subject.annotate`, `ResultWriter` (`print` and `reservationDirective`), and a `Subject` helper to read a 24-bit value. CLAUDE.md lists the types.

Done when: both types can be declared in a `.flo` file and print under `.long`/`.lint` with the right value, with a fixture that round-trips through 64tass.

## Decisions

- **Names: `long` and `slong`.** `long` is 64tass's own name for the unsigned one (`$c010 long score` prints `.long $123456`); `slong` follows deflower's `s` prefix for signed types, like `sbyte`/`sword`/`sdword` (`$c013 slong offset` prints `.lint -3`).
