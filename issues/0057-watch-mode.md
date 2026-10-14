---
title: Add a flag to run deflower as a live server that re-runs on file changes
status: open
priority: high
labels: enhancement
---

The suggested way to work is to re-run the disassembler on every save of the `.flo` file and read `out/<binary>.asm` as it updates (CLAUDE.md, Purpose). Today `Deflower.main` does a single run, so that loop needs an external file watcher.

**Blocked by [0059](0059-convert-to-nim.md).** Do this only after the conversion to Nim, so the watcher is written once, in Nim, rather than in Java and then ported.

Want: a flag, e.g. `--watch`, that keeps deflower running. It does one run at start, then watches the files and runs again whenever one changes.

What to watch:
- the `.flo` file;
- every binary its `deflower` lines load (`.prg`, `.vsf`), since a new snapshot should also trigger a run;
- a `deflower` line can be added or removed, so the set of watched binaries has to be recomputed after each parse.

Behaviour:
- A run that fails (parse error, area conflict, duplicate label) prints its errors and keeps watching; the next save tries again. Today an error ends the program or skips output, which is right for a single run but not here.
- Editors save in several steps (temp file, rename), so debounce: wait until changes settle for a short time before running.
- One run at a time: a change during a run triggers one more run after it, not several.
- Print a short line per run (time, success or error count), so the terminal shows that the save was picked up.

Open questions:
- **Server or watcher.** A plain watch loop that rewrites `out/*.asm` covers the workflow above. "Server" could also mean serving the output, e.g. over HTTP to a browser page that reloads by itself, or to an editor plugin. Decide whether that is part of this issue or a follow-up.
- **Old output on error.** Today `Deflower` clears `out/` at the start of each run, so a failed run leaves no `.asm` at all. In watch mode, keeping the last good output may be better while the user fixes the error.
- `--watch` should be listed in [0056](0056-help-flag.md)'s usage. (Paths are file-system paths since [0101](0101-run-from-the-command-line.md), so the watcher can use them as they are.)

Implementation hint: file-system watchers often watch directories, not files (Java's `java.nio.file.WatchService` and Linux inotify-based ones do), so register the directories that hold the watched files and filter events by file name.

Done when: `--watch <file.flo>` runs once, then re-runs after a change to the `.flo` file or one of its binaries, survives a run with errors, and a test covers at least the re-run after a change to the `.flo` file.

## Decisions

- **A watching server, terminal only.** `--watch` keeps deflower running, watches the files, re-runs on a change and prints each run's stdout and/or stderr to the terminal. No browser page, HTTP or editor plugin.
- **Keep the last good output on error.** A failed run prints its errors and leaves `out/*.asm` as it was; only a successful run replaces it.
