---
title: ./deflower fails with "nim: not found" outside a login shell
status: rejected
labels: bug
---

`./deflower` builds `bin/deflower` with `nim c` when the binary is missing or a source is newer. `nim` from choosenim lives in `~/.nimble/bin`, which a login shell adds to `PATH` but a non-interactive one (scripts, editors, Claude Code's Bash tool) doesn't:

```
/home/danny/dev/deflower/deflower: 7: nim: not found
```

Then the script exits with 2 and runs nothing, even in the case where a (slightly stale) `bin/deflower` exists.

Done when the script:
- looks for `nim` on `PATH`, then in `$HOME/.nimble/bin`, before giving up;
- when no `nim` is found but `bin/deflower` exists, warns that it may be stale and runs it;
- only fails when there's neither, with a message saying where it looked.

## Closing note

Rejected: not a Deflower problem. `nim` missing from a non-login shell's `PATH` is the machine's setup; export `~/.nimble/bin` in `~/.profile` or in Claude Code's `env` setting. Running a possibly stale `bin/deflower` with a warning would quietly give output from old code, so the launcher keeps failing when it can't build.
