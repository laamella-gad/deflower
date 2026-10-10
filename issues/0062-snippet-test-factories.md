---
title: Replace the fixture tests with two SnippetTestFactories
status: open
priority: medium
labels: test
---

Today every fixture is a directory (`src/test/resources/<fixture>/` with a `.flo`, a binary and `expected.asm`) plus a hand-written `@Test` method in `DeflowerTest` that calls `assertDeflowered`. The small fixtures' `.prg` files are built by hand (`printf` of the bytes), so the input is unreadable, and only the `.asm` output is checked, not the tracing the run prints.

Use snippets-test's dynamic tests instead (`SnippetTestFactory` with JUnit 5's `@TestFactory`, from the same `snippets-test-junit5-core` library the tests already use; see its [readme](https://github.com/laamella-gad/snippets-test-junit5)). One snippet file is one test: the inputs, then the expectations, which are created on the first run and compared after that. Two factories:

**1. Short tests.** For the small, purpose-built cases, one per feature or bug.
- Input parts: a bit of assembly, and the content of a `.flo` file, written out in the snippet itself (not a file name). There is no `.flo` file for a short test.
- The `.flo` part starts with its own `deflower` line, e.g. `deflower test.prg`. The factory assembles the assembly and writes the result under that name in a temporary directory, writes the `.flo` content next to it, and runs the disassembler on it.
- Outputs:
  1. what the run printed, stdout and stderr together, so an error run shows its errors here;
  2. the resulting `.asm` file, or nothing when the run had errors and wrote none.
- The test also reassembles the output `.asm` and checks that it gives the same bytes as the input (skipped when the run had errors). Today that check is done by hand (CLAUDE.md, Test-driven workflow).
- The assembly is readable source instead of a hand-built `.prg`.

**2. Large projects.** For the real programs: squirm, zwark, tcmine.
- Input: the file name of the project's `.flo` file, e.g. `zwark/zwark.flo`. Its own `deflower` line names the binary (`.vsf` or `.prg`), so nothing is repeated, and a `.flo` with several `deflower` lines still works.
- The test runs the disassembler and outputs the same two expectations as above. A `.flo` with several runs gives one `.asm` per run; show them one after the other in the second expectation, each under its file name.

### Assembler: a text parser for mpu6502

The assembling is done by mpu6502 (the user's own library, see [0059](0059-convert-to-nim.md)), not by 64tass, so the tests need no external tool. mpu6502 has an assembler (`com.laamella.mpu6502.assembler.Assembler`), but it is a Java builder API (`org(0x1000)`, `instruction(LDA_IMM, 15)`, `bytes(...)`) with no text parser. Add one to mpu6502 first, as its own piece of work there:
- It reads a 64tass-like subset: `*=`, every opcode in every addressing mode (illegal opcodes included), labels, `label = value`, and the data directives.
- For the input side, that subset is whatever the short tests use.
- For the round trip, it must also read everything deflower writes: `.virtual`/`.endv`, `.byte`, `.word`, `.dword`, `.addr`, `.fill`, `.text` with `.enc "screen"`/`"none"`, `label + $offset` operands, and the `@w` prefix ([0053](0053-force-absolute-operand-on-zero-page-label.md)). When deflower's output gains new syntax, the parser has to follow.
- Writing it in mpu6502 means it carries over to the planned Nim port of mpu6502.

This issue depends on that parser.

### Examples

The separators are only a suggestion: `>>> … <<<` for the description, `===` between the input parts, `^^^` after the inputs, `~~~` between the expectations and `vvv` at the end. The expected parts are what the current code prints for these inputs, with paths printed relative to the `.flo` file (see below).

A short test, `absolute-operand.txt`. The first part is assembly, the second the `.flo` content:

```
>>> an absolute operand below $100 keeps its absolute form <<<
*=$c000
        lda @w $0010
        sta $10
        rts
===
deflower test.prg
$10 virtual byte counter
$c000 code entry
^^^
Reading test.prg
Reading prg test.prg
load address 49152
Marking area of 1 byte at 10 "counter"
Will disassemble from C000
Starting flow analysis.
Writing out/test.asm
~~~

.virtual $0010
counter:		.byte	?
.endv

*=$C000

entry:
		LDA @w counter
		STA counter
		RTS
vvv
```

A short test whose run fails. The output part shows the error, and the `.asm` part is empty:

```
>>> overlapping word and byte is an area conflict <<<
*=$c000
        .word $beef
===
deflower test.prg
$c000 word value
$c001 byte inside
^^^
…
Area conflict at $C001: … overwrites …
~~~
vvv
```

A large-project test, `zwark.txt`. The input is the `.flo` file name; stdout and the `.asm` are long, shown shortened here:

```
>>> zwark <<<
zwark/zwark.flo
^^^
Reading zwark.vsf
…
Writing out/zwark.asm
~~~
…
vvv
```

### Decisions

- **Paths in the output.** Today deflower prints absolute paths ("Reading /home/…/demo.prg"), which differ per machine. Change deflower itself to print paths relative to the `.flo` file's directory, as in the examples. That also helps users.
- **Capturing.** The tracing goes through `System.out` and the errors through `System.err`; capture both around the run into the first expectation, in the order they were printed.
- **Separators.** Use a `SnippetFileFormat` whose separators can't appear in assembly or `.flo` text (`;` and `#` are comments in both, and in 64tass a line of only `-` or `+` characters is an anonymous label, so `---` is a poor choice). The ones in the examples qualify.

Done when: the mpu6502 text parser exists; every existing fixture is a snippet in one of the two factories, with the same `.asm` output as its current `expected.asm`; the existing error tests (area conflict, duplicate label, zero size, image past `$FFFF`, …) are short-test snippets; every short test passes the round trip; the per-fixture `@Test` methods, the hand-built `.prg` files of the small fixtures and the old `expected.asm` files are gone; and CLAUDE.md's test section describes the new layout.

Relation to [0059](0059-convert-to-nim.md): the Nim port plans to convert snippets-test's core and mpu6502 to Nim too. Doing this first means the port carries over snippet files rather than fixture directories.
