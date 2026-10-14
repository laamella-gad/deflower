---
title: Silence a warning in the .flo file once it is understood
status: open
priority: low
labels: enhancement
---

Since [0077](0077-analysis-warnings-report.md), a run prints warnings for suspect spots: a jump into data or into the middle of an instruction, a `jsr` returning into data, and so on. Some are understood and stay. [0068](0068-inline-data-after-jsr.md) removed the biggest group (37 `jsr returns into data` lines in `3dgolf_snap`), but every finished fixture with a decruncher or banking still warns: `jmp $ea31 (kernal_irq) goes into data` in `3dgolf_snap` only because the RAM under the KERNAL holds a shape ([0069](0069-one-label-per-address-ignores-banking.md), [0102](0102-rom-banked-in-over-ram-data.md)), `jmp $0116 goes into memory the image doesn't load` for code a decruncher copies there first, and since [0103](0103-init-marks-used-memory-untouched.md) `unused_6fbe is used by $c752` in `bigmac`, from dead code. A finished disassembly can't run clean, and a new warning is hard to spot among the old ones.

Want: a way to accept a warning in the `.flo` file, so it no longer prints.

## To decide

- **Form.** A comment keyword above the line at the warning's address (e.g. `; ok: returns into data`), a line of its own (`$a19d ok`), or a keyword on the annotation line.
- **Scope.** One warning, all warnings at that address, or all warnings of one kind in a range.
- **Stale acceptances.** Whether an acceptance that matches no warning is itself reported, so it doesn't outlive a fix.

Done when: a short snippet accepts one of two warnings and prints only the other.
