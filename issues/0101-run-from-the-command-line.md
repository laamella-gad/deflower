---
title: Run deflower from the command line without assembling a classpath by hand
status: done
labels: enhancement
---

There is no exec plugin and no runnable artifact, so every run of `--verify`, `--init` or `--dump` outside the IDE needs a hand-built `java -cp` line with the classes, the ANTLR runtime and mpu6502 from `~/.m2`. `Deflower.main` also takes the `.flo` file as a classpath-relative path, so it has to sit under `src/test/resources` or the directory has to be added to the classpath, while `--init` and `--dump` take file system paths.

[0019](0019-ship-as-single-executable.md) asked for a single executable and was superseded by the conversion to Nim ([0059](0059-convert-to-nim.md)). Until that lands, a small step is enough:
- a `deflower` launcher script in the repository that runs the built classes with the dependency classpath (e.g. from `mvn dependency:build-classpath`, cached in `target/`), or the `exec-maven-plugin` configured so `mvn -o -q exec:java -Dexec.args="..."` works;
- `Deflower.main` taking the `.flo` file as a file system path, like `--init` and `--dump`, so `./deflower --verify some/dir/game.flo` works anywhere. The large snippets go through `DeflowerTest`, not `main`, so they don't depend on the classpath form.

Done when: `./deflower --verify src/test/resources/squirm/squirm.flo`, `./deflower --init <file>` and `./deflower --dump <file> <range>` work from the repository root after `mvn -o compile`, and `CLAUDE.md`'s Commands section says so.

## Closing note

`deflower` in the repository root is a launcher script: it runs `Deflower.main` on `target/classes` with the dependency classpath, which `mvn -o dependency:build-classpath` writes to `target/classpath.txt` once and again when `pom.xml` is newer. It works offline and from any directory, and complains when `mvn -o compile` hasn't run yet. `main` now takes the `.flo` file as a file system path, like `--init` and `--dump`, and prints "No such file" with exit code 2 for a missing one; the classpath-relative `Deflower.deflower(String)` is gone, as nothing else used it. A run writes `out/` next to the `.flo` file, so running on a `.flo` file under `src/test/resources` would leave one there: `out` is now in `.gitignore`.

Tried: `./deflower --verify src/test/resources/squirm/squirm.flo` (0 differ, 0 gaps), the same from inside the squirm directory, `--dump` and `--init` on 1nvader.prg, a missing file and no arguments.
