---
title: Silence a warning in the .flo file once it is understood
status: open
priority: low
labels: enhancement
---

Since [0077](0077-analysis-warnings-report.md), a run prints warnings for suspect spots: a jump into data or into the middle of an instruction, a `jsr` returning into data, and so on. Some are understood and stay. In `3dgolf_snap`, 37 `jsr returns into data` lines are a print routine that reads its text after the `jsr` ([0068](0068-inline-data-after-jsr.md)), and `jmp $ea31` goes into data only because the RAM under the KERNAL holds a shape ([0069](0069-one-label-per-address-ignores-banking.md)). A finished disassembly can't run clean, and a new warning is hard to spot among the old ones.

Want: a way to accept a warning in the `.flo` file, so it no longer prints.

## To decide

- **Form.** A comment keyword above the line at the warning's address (e.g. `; ok: returns into data`), a line of its own (`$a19d ok`), or a keyword on the annotation line.
- **Scope.** One warning, all warnings at that address, or all warnings of one kind in a range.
- **Stale acceptances.** Whether an acceptance that matches no warning is itself reported, so it doesn't outlive a fix.
- **0068 first.** Inline data after a `jsr` would remove most of `3dgolf_snap`'s warnings without any silencing.

Done when: a short snippet accepts one of two warnings and prints only the other.
