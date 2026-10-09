---
title: Auto-generated labels start with `_`, which makes them 64tass local labels
status: done
labels: bug
---

`Subject.ensureLabelled` names auto-generated labels `_XXXX_CODE`, `_XXXX_DATA` and `_XXXX_POINTER`. In 64tass a symbol that starts with `_` is a cheap local label: it is only visible between two normal labels. A reference from another scope fails with "not defined symbol".

Found while doing issue 0015. Before any change:

- `squirm/expected.asm` fails at `JSR _241C_CODE`, and `zwark/expected.asm` at `JSR _9CD5_CODE`. Neither reassembles.
- tcmine and multi only reassemble because all their auto-labels happen to be referenced from inside the scope that defines them. 0015's extra data labels break that: `_033F_DATA` is defined before the first normal label, so `LDX _033F_DATA` can't see it.

Fix: give auto-labels a name that starts with a letter: a one-letter kind prefix and the address, `lXXXX`, `dXXXX`, `pXXXX`. It can't start with the address, because a hex address can start with a digit.

Done when: auto-labels use the new names, all expectations are regenerated and differ only in those names, and the generated output no longer fails on an undefined auto-label.

## Closing note

`Subject.ensureLabelled` now names auto-labels with a one-letter kind prefix and the address: `lXXXX`, `dXXXX`, `pXXXX`. The kind hints passed by `Subject.addPotentialCodeLocation` and `FlowAnalyser` are now `l`, `d` and `p`. The address digits stay uppercase, as all hex in the output does for now (see [0042](0042-lowercase-generated-assembly.md)). No `.flo` file or test referred to a generated name.

The six expectations that contain auto-labels (indirectjmp, squirm, zwark, tcmine, multi a/b) were regenerated. Each new file is identical to the old one with the old names replaced by the new ones by a regex (`_XXXX_CODE` → `lXXXX`, `_XXXX_DATA` → `dXXXX`, `_XXXX_POINTER` → `pXXXX`), so nothing else in the output changed.

64tass now assembles all of them:
- squirm and multi/b used to fail on an undefined `_XXXX_CODE`, and now assemble.
- zwark assembles with `-i` (NMOS illegal opcodes, for its `ISC`).
- tcmine, multi/a and indirectjmp assemble to the same bytes as before.

42/42 tests green.
