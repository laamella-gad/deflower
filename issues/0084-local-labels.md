---
title: Tell routine labels apart from local labels inside a routine
status: done
labels: enhancement
---

Every label is the same kind of label today: a routine's name, a variable and the target of a branch two instructions down all print as `name:` at column 0. In the real programs most labels are branch targets inside a routine (`l3395`, `l241E`, `more_chars`), so the output doesn't show where one routine ends and the next begins.

The cross-references of [0076](0076-cross-reference-comments.md) show the cost. A referrer is named by the nearest label before its instruction, and in `squirm` that is usually a branch target, not the routine:

```
; written by: l3395, l33A4, initialize_pointers
snake_0_head:
```

## Would it help with the cross-references?

Yes. If labels are split into routine labels and local labels, the referrer can be named by the nearest *routine* label before the instruction. `l3395` and `l33A4` above would then print as the routine they're in. As a side effect, the lists get shorter, because several local labels of one routine collapse into one name, and the 0076 rule "skip a reference from the label itself" could become "skip a reference from inside the same routine", which drops the many short `jumped to by:` comments on loop targets.

This needs only the distinction inside Deflower, not a change in the printed labels. Printing them as 64tass local labels is a separate step (see below).

## A fuller rule, for later

Deciding by where the references come from:
- **Routine labels:** every `.flo` `code` entry and every `jsr` target. Data labels and labels on uncovered memory aren't in a routine at all.
- **Local labels:** an auto `lXXXX` label that is only reached by branches and `jmp`s from inside its own routine, the code between the routine label before it and the next one.
- A `jmp` or branch from another routine makes the target a routine label (a tail call, or a shared exit).

Making a label a routine label splits a routine in two, which can move other labels' references outside their routine. The set has to be computed until it stops changing.

## Decisions

The simplest version for now; the rest waits until it proves too coarse.

- **Which labels are local.** An auto `lXXXX` label is local unless it is a `jsr` target. Every other label is a routine label: `code` entries, `jsr` targets and every label named in the `.flo` file. No check of where the references come from and no repeat-until-stable: a `jmp` or branch from another routine doesn't change a label's kind. Naming a branch target in the `.flo` file therefore makes it a routine label.
- **Use.** Only the cross-references use it: a referrer is named by the nearest routine label at or before its instruction (`$XXXX` when there is none). The rule that skips a reference from the label itself stays as it is.
- **Printing.** Unchanged. Local labels print as today, not as 64tass `_` or anonymous labels, so reassembly can't break.
- **Not in this issue.** Blank lines only above routine labels ([0073](0073-blank-line-only-after-flow-end.md)), skipping references from inside the same routine, and a way to mark a named label local in the `.flo` file. Self-modifying writes need no rule: references don't change a label's kind.

Done when: a small fixture shows a routine with local branch targets referring to data and to other routines, its cross-references name the routine instead of the branch targets, and the changed expectations are reviewed with snipsert.

## Closing note

A `Label` (`MemoryLocation.label`) holds the name and whether it is local: local for an auto label created by `Subject.addPotentialCodeLocation` for a branch or `jmp` target. `Subject.addCallTarget`, which `FlowAnalyser` now uses for `jsr`, makes it a routine label, whichever reference labelled the target first. `CrossReferences` skips local labels when it looks back for the referrer.

Fixture `routines` shows local loop and branch targets inside two routines, a `jmp` to a local label, and a target reached both by a branch and a `jsr`, which stays a routine. Its output reassembles to the `.prg`. In the other fixtures only cross-reference lines changed: `squirm`'s longest line went from 421 to 357 characters.

A side effect of keeping the self-reference rule as it was: a loop now lists its own routine (`jumped to by: entry` above `lC002` in `routines`), because the referrer is the routine, not the loop label. Skipping references from inside the same routine, listed as not in this issue, would remove those.
