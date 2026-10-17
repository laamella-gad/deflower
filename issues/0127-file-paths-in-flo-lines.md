---
title: Allow paths with directories in the file names of .flo lines
status: open
priority: medium
labels: enhancement
---

A `.flo` file can only name a file in its own directory. The file names of `deflower`, `load`, `include` and `export` lines are an `ID` token, `[A-Za-z0-9._?]+` (`src/deflower/flo/flo.ldb:47`), so a `/` stops the line:

```
deflower original/grotten.prg
```

```
Failed to parse grotten.flo:
line 6: unexpected '/'
```

Quoting the name doesn't help either (`unexpected '"'`).

Found in grotten_van_oberon (`/home/danny/IdeaProjects/grotten_van_oberon`): the reference PRGs were moved out of the project root into `original/`, but the Deflower input had to stay next to `grotten.flo`. The project now keeps `grotten.flo`, `grotten.prg` and `out/` together in `disasm/` as a workaround.

Done when:
- `deflower`, `load` and `include` accept a relative path (`original/grotten.prg`, `../shared/c64_extra.flo`), still resolved against the `.flo` file's directory (`runner.nim:13`, `basePath / image.name`). Absolute paths may be allowed too.
- The output name is still `out/<file name without extension>.asm`, from the last part of the path, not `out/original/grotten.asm`.
- `export` file names stay plain names (they go to `out/`), or a path there is rejected with a clear error.
- Spaces in names are optional: a quoted name (`"my game.prg"`) would cover them, if wanted.
- `README.md` ("The .flo format") says what a file name may be, and tests cover a `deflower` and a `load` line with a subdirectory.
