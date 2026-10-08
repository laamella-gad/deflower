---
title: A second deflower line wipes earlier annotations
status: open
labels: bug
---

`SubjectConfigurer.clearMemory()` (around line 80) replaces every `MemoryLocation`, so areas and labels set before a second `deflower` line are lost. This conflicts with the workflow of annotating a `.flo` file incrementally.

Found by reading the code. Not reproduced.

Done when: a second `deflower` line either keeps earlier annotations or is rejected with a clear error, and a test covers the chosen behaviour.

There should only be one "deflower" line per file, and it should be the first line. Can this be fixed in the grammar?