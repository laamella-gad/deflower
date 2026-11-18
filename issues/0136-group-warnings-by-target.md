---
title: Group repeated warnings about the same target
status: done
labels: enhancement
---

The first run on The Write Stuff 128 (`~/dev/c64-productivity/tws128`) printed 139 warnings. Almost all are the same few lines, once per call site:

```
warning: $2bd9: jsr $0250 (l0250) goes into memory the image doesn't load
warning: $2bfc: jsr $0250 (l0250) goes into memory the image doesn't load
warning: $2c67: jsr $0250 (l0250) goes into memory the image doesn't load
... (14 for $0250, 12 for $023e, ...)
```

About eight targets cause all of them. The few warnings that matter (`jsr $430a goes into the middle of the instruction at $4308`) are buried.

Want: warnings about a target (flow into unloaded memory, into data, into an untouched or unused range) print once per target, with the sites:

```
warning: $0250 (l0250): 14 jsr/jmp go into memory the image doesn't load: $2bd9, $2bfc, $2c67, $2c75, ... 
```

Warnings about a site (the middle of an instruction, a jam) stay one per line. Accepting a whole group with one line would fit [0089](0089-silence-accepted-warnings.md).

## Closing note

`Subject.warningLines` groups the flow warnings (`warnFlowInto`, which records the target, what it goes into and how) when two or more share a target and kind: `warning: $0250 (l0250): 4 flows go into memory the image doesn't load: jsr $c000, $c003, $c008; jmp $c00b`. One flow keeps its own line. Warnings about a site (a code entry, a jam, an instruction running into an area) are unchanged; the skeleton range warning was already one per range. Snippet `short/grouped_warnings.txt`; zwark's two `decrunch_table` warnings became one.
