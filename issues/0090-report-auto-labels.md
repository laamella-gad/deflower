---
title: Report the auto labels left, as a count in verify and a list in the map
status: open
priority: medium
labels: enhancement
---

Every target the user hasn't named gets an auto label: `lXXXX` for code, `dXXXX` for data, `aXXXX` for an address. Each one marks a spot nobody has looked at yet, so the number left measures progress the way verify's gaps do ([0075](0075-verify-flag.md)).

Until [0077](0077-analysis-warnings-report.md), each run printed an "Unnamed target: l2441 from address $3b74" line per auto label, to point out where to investigate next. 0077 dropped that with the rest of the tracing. In that form it didn't work well: zwark had 145 of these lines, unsorted, among the other tracing, printed again on every run, with the referencing instruction given only as a number. The labels still show in the `.asm` with their cross-references, but nothing lists them.

Want:
1. **A count in the verify line**, e.g. `Verify out/zwark.asm: 6991 bytes emitted, 0 differ, 58545 virtual, 0 gaps, 145 auto labels`. It is one number that goes down as the work goes on. It doesn't change the exit code: an auto label is unfinished, not wrong.
2. **A list in `out/<binary>.map`**, one line per auto label with the routines that refer to it, named the way the cross-references name them, e.g. `$2441 auto l2441 (called by reset_everything)`.

They are not warnings: an unnamed target isn't suspect.

## To decide

- **Which labels count.** All auto labels, or not the local ones (branch and `jmp` targets inside a routine, [0084](0084-local-labels.md)), which often don't need a name.
- **Map line form.** The kind of reference (`called by`, `jumped to by`, `read by`, `written by`), and whether the list goes in its own section or among the area lines by address.
- **Dropped labels.** Auto labels on memory that isn't printed (included areas dropped as unused) are left out.

Writing them as `$2441 code l2441` lines ready to rename belongs to the `.flo` skeleton ([0079](0079-generate-flo-skeleton.md)).

Done when: the verify line counts the auto labels, the map lists them with their referrers, and a short snippet shows both.
