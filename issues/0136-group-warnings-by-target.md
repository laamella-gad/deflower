---
title: Group repeated warnings about the same target
status: open
priority: medium
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
