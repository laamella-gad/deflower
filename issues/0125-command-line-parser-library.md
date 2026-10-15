---
title: Parse the command line with a library
status: open
priority: low
labels: cleanup
---

`command` in `src/deflower.nim` reads the arguments by hand: `--help`/`-h` alone, `--init <file>`, `--dump`/`--find`/`--strings` followed by the file and the rest, else a loop over `--verify`, `--watch` and one `.flo` file. The usage lines it prints on bad arguments are written out separately from `src/deflower/help.txt`, which repeats them. Every new flag or mode means changing the loop, the usage lines and the help text by hand, and nothing keeps them in step.

Want: a Nim command line parser library reads the arguments, so that the modes, flags and their arguments are declared once, and bad arguments get a clear message (`unknown flag --frobnicate`, `--init needs a file`) instead of only the usage block.

## To decide

- **Which library.** Candidates:
  - `std/parseopt`: in the standard library, no dependency, but only a tokenizer; the checking stays hand-written.
  - [cligen](https://github.com/c-blake/cligen): builds the parser and the help from proc signatures; supports subcommands (`dispatchMulti`).
  - [argparse](https://github.com/iffy/nim-argparse): a declarative DSL with subcommands, flags, options and positional arguments, and generated help.
  - [docopt.nim](https://github.com/docopt/docopt.nim): parses the arguments against a usage text, so the usage in `help.txt` would be the specification itself.
- **Modes as flags or as subcommands.** `--init`, `--dump`, `--find` and `--strings` are modes written as flags. Most libraries treat these as subcommands (`deflower init game.prg`). Keep the flags (the snippet tests and `CLAUDE.md` use them), or switch to subcommands.
- **The look arguments.** `--find`'s `[in <start>-<end>]` and `--strings`' `[<start>-<end>] [min <n>]` are small word-based syntaxes that `look` reads itself. They may stay that way, as positional arguments the library passes through.
- **The name of the format flag** (see Decisions): e.g. `--help-flo`, `--flo-help` or `--format`.

Done when: the command line is parsed by the chosen library, the usage lines aren't written out twice, bad arguments name the problem and exit 2, `--help` prints the command line usage and the format flag prints the `.flo` summary, both exiting 0, and `tests/test_command.nim` covers them and the error messages.

Related: [0056](0056-help-flag.md) added `--help` and `deflower.command(args)`.

## Decisions

- **The `.flo` summary moves to a flag of its own** (decided 2026-10-15). `--help` covers only the command line, so the library can make it from what is declared, and another flag prints the `.flo` format summary that `help.txt` holds now. `README.md` and `CLAUDE.md` name both.
