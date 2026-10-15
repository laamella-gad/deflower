# Deflower

Deflower semi-automatically disassembles 6502 binaries, made for the Commodore 64. It traces the code by itself, following the control flow from the entry points you give it. You supply the rest: labels, comments, and what the data is (text, bytes, words, address tables, more code entries). Those annotations live in a `.flo` file, and the work is a loop: run Deflower, read the output, annotate, run again. The output is an assembly file for [64tass](https://tass64.sourceforge.net/) that assembles back to the same bytes.

## Building

Deflower is written in [Nim](https://nim-lang.org/) 2.2 and needs nothing else.

- `nimble build` writes the executable `bin/deflower`.
- The `./deflower` script runs it from anywhere, and rebuilds it first when it is missing or a source is newer.
- `nimble test` runs the tests.
- `nimble flo` regenerates the `.flo` parser from its grammar, `src/deflower/flo/flo.ldb`, with [lindeboom](../nim_parser_generator) (its sources in `LINDEBOOM_SRC`, else next to this project). The generated parser and lindeboom's runtime are committed in `src/deflower/flo/`, so building needs no lindeboom; a test fails when they are out of date with the grammar.

## Getting started

1. `./deflower --init game.prg` (or a VICE snapshot, `game.vsf`) writes `game.flo` next to it: a skeleton with what can be read from the file, as comments, then the `deflower` line, `code` lines for the entry points it found, and the matching includes.
2. `./deflower --watch --verify game.flo` runs the disassembly, writes `out/game.asm`, and runs it again whenever you save `game.flo`.
3. Read `out/game.asm`, the warnings and the verify report. Add labels, comments, data types and code entries to `game.flo`, and save.

A disassembly reassembles to the original bytes when it verifies with 0 differ, and is complete when it also has 0 gaps: every loaded byte is code or declared data. That isn't the end, though: the goal is to understand the program, so name its routines and variables, type its data and explain what it does.

## The command line

```
deflower [--verify] [--watch] <file.flo>
deflower --init <file> [at <address>] [from <offset>] [size <n>]
deflower --dump <file> [<options>] <start>-<end>
deflower --find <file> [<options>] <address or bytes> [in <start>-<end>]
deflower --strings <file> [<options>] [<start>-<end>] [min <n>]
deflower --help
```

The `<file>` of `--init`, `--dump`, `--find` and `--strings` is a `.vsf`, `.prg` or `.bin`, with the options of a [`deflower` line](#deflower-file-at-address-from-offset-size-n) after it: `at`, `from` and `size`. A `.bin` needs `at`.

All paths are file system paths. Numbers are decimal, or hex with a `$` prefix (quote it in the shell: `'$c000-$c100'`). A range's end is exclusive, as in a `.flo` file.

The exit code is 0 on success, 1 when a run has errors or doesn't verify (or `--init` finds a `.flo` file there already), and 2 for bad arguments or a missing file.

### Disassembling: `deflower <file.flo>`

Runs the `.flo` file: every `deflower` line in it is a run that loads a binary (and the files of its `load` lines), applies the annotations and traces the code. Each run writes into `out/` next to the `.flo` file, which is cleared first:
- `out/<binary>.asm`, the disassembly (see [The output](#the-output));
- `out/<binary>.map`, the memory map: one line per code run (split at routine labels), per array and per gap, e.g. `$c007-$c009 word table`;
- the exported binaries (`export` on a data line).

A run with errors (an area conflict, say) writes no `.asm`. Besides those, a run prints only warnings, errors, and the files it writes.

### Verifying: `--verify`

After writing each `.asm`, reassembles it with Deflower's built-in assembler and compares every byte with the loaded binary:

```
Verify out/game.asm: 13 bytes emitted, 1 differ, 48 virtual, 1 gap
differ $c001 expected $07 got $08
gap $c00d-$c010
```

The first 10 differences are listed. A gap is loaded memory that no area covers; the `gap` lines can be pasted into the `.flo` file. An included virtual area left out as unused still counts as covered. The exit code is 1 when anything differs or there is a gap.

### Watching: `--watch`

Does one run, then another whenever the `.flo` file, a `.flo` file it includes from disk, or a binary it loads changes, until interrupted with Ctrl-C. It waits for the files to settle, so an editor's save makes one run. A run with errors leaves all of `out/` as it was, so the last good output stays readable. Each run ends with a status line:

```
12:03:41 ok, watching game.flo
```

or `doesn't verify` (with `--verify`), or `failed, out/ unchanged`.

### Starting: `--init`

Takes a `.vsf` VICE snapshot, a `.prg` or a `.bin` and writes a `.flo` skeleton next to it, `<file without extension>.flo`. It won't overwrite an existing `.flo` file. The skeleton holds:
- the facts, as `;` comments. For a snapshot: the banking, the CPU registers, the stack, the IRQ/BRK/NMI vectors (and the hardware vectors while the KERNAL is banked out), each marked ROM, RAM or untouched RAM, changed KERNAL vectors, the video setup (VIC bank, mode, screen, character set or bitmap, sprites), the interrupt sources, the BASIC program and its `SYS`, and a patched CHRGET. For a `.prg` or `.bin`: the load range and the `SYS` of a BASIC stub. The video and VIC interrupts are only read from x64sc snapshots of VICE 3.x;
- the `deflower` line, with the options given;
- `code` lines for the entry points found (`snapshot_pc`, `irq`, `nmi`, ...), except those in ROM, the zero page or untouched memory;
- `untouched_xxxx` ranges from `$0400` up that still hold VICE's power-on pattern, and `unused_xxxx` ranges that hold only zeroes. Deflower warns when an instruction refers into one of them, as that range is in use after all;
- the includes that match the banking.

### Looking at the bytes: `--dump`

Prints the range as hex, 16 bytes a line from its start, then as PETSCII and as screen codes. Both text columns read the bytes with the lower/upper case character set and show every character that has a printable counterpart (letters, digits, punctuation, `£↑←`, reversed or not), graphics and control codes as `.`. Memory the file doesn't load shows as `..`. The range can be pasted from a verify `gap` line.

### Searching: `--find`

Searches the file's memory, or the range after `in`, and prints each hit's address, kind, and the 8 bytes from there.
- One number above 255, or one hex number of 3 or 4 digits, is an address. It is found as a word (`addr`), as the address minus one (`rta`, an `rts` dispatch table), and as a low and a high byte at the same index in two tables 2 to 256 bytes apart (`lo/hi`).
- Anything else is a byte sequence: `--find game.prg '$a9 $00 $8d'`.

### Finding text: `--strings`

Lists the stretches that read as PETSCII (`ascii`) or screen codes (`screencode`): at least 6 characters besides spaces (or `min <n>`), at least half of them letters and half of them different, the letters in one case apart from a capital starting a word. Each prints as a line to paste into the `.flo` file, then the text:
- `$c100 ascii[until $00]` when it ends in `$00` or `$ff`;
- `$c100 ascii[lengthbyte]` when its length comes before it;
- `$c100-$c10c ascii` otherwise.

These are only candidates.

## The .flo format

A `.flo` file says how to disassemble one or more binaries. One statement per line; blank lines and indentation are ignored. A line that doesn't fit the format stops the whole file: `Failed to parse <file>:`, then one `line N: expected <parts>, found <token>` per bad line.

```
; The game, loaded at $0801.
deflower game.prg
include c64.flo

$0810 code start
$0900 code irq
$d020 virtual byte border_color
$1000 screencode[20] title_text
$1014-$1020 addr level_table
$2c75 code print_inline (ascii[until $ff] text)
```

### `deflower <file> [at <address>] [from <offset>] [size <n>]`

Starts a run: loads a file, relative to the `.flo` file's directory. The lines after it, up to the next `deflower` line, annotate that binary, and its output is `out/<file without extension>.asm`. It must come before any annotation line. The file is one of:
- a `.vsf` VICE snapshot: its 64K of RAM, without options;
- a `.prg`: a 2-byte load address, then the bytes. `at` loads them at another address;
- a `.bin`: only the bytes, loaded at the `at` address, which it needs. `from` skips that many bytes of the file first and `size` takes only that many: `deflower kernal.bin at $e000`, `deflower cartridge.bin at $8000 from $50 size $2000`.

A file that runs past `$ffff` is an error.

### `load <file> [at <address>] [from <offset>] [size <n>]`

Loads one more `.prg` or `.bin` into the run, with the options of the `deflower` line, e.g. a program's second part or the overlay it loads at run time:

```
deflower game.prg
load levels.prg
load music.bin at $1000
```

The files load in order, the `deflower` line's first, and a later one wins where they overlap, without a warning: a part can patch another, or a snapshot. The run's output is still the one `.asm`, with each part under its own `*=` origin. A `load` line comes after a `deflower` line and only in the `.flo` file itself, not in an included one or in a block.

The words `load`, `at`, `from` and `size` are only keywords on a `deflower` or `load` line: elsewhere they can be labels, like the KERNAL's `load`.

### `include <file>`

Reads the lines of another `.flo` file into the current run, e.g. a machine's I/O registers and ROM routines. The file is looked up relative to the including file; when there is none, a file built into Deflower is used:
- `c64.flo`: all of the C64 pieces below, the view with `$01 = $37`;
- `c64_zeropage.flo`;
- `c64_system.flo`: `$0100-$0800`, the stack, KERNAL workspace and vectors, the screen;
- `c64_io.flo`;
- `c64_basic.flo`;
- `c64_kernal.flo`.

Included files may include others, but can't contain `deflower` lines.

A VICE snapshot holds the RAM only, not the ROMs or the I/O banked over it, so without these lines a jump into the KERNAL traces the RAM underneath. Include the pieces the program has banked in.

Included lines are weak: any line of the including file that covers the same memory or names the same address wins, whatever the order, and an included element it overlaps is dropped. Included areas still stop the code tracing. Included virtual areas and included labels on memory no area covers are only printed when an instruction's operand or an `.addr` value refers to them.

### `; text` or `# text`

A comment, on a line of its own (not after an annotation). It is printed above the next annotation line's address in the output; consecutive comment lines stay together.

### Annotation lines

```
<address or range> [virtual] [<type>[<size>]] [<label>] [(<parameters>)] [noreturn] [export <file>] [{]
```

The parts come in exactly this order, each at most once:

- **address**: `$hex` (either case) or decimal, e.g. `$c000`, `49152`.
  **range**: `start-end`, with the end EXCLUSIVE (`$c006-$c008` is two bytes). A range sets the element count to whatever fits; a `[size]` on the same line is ignored.
- **virtual**: memory the program uses but doesn't contain (I/O, zero page, screen). Output as a `.virtual` reservation, not as data. A data element on memory the binary doesn't load is made virtual anyway, with a warning, so it isn't printed as zero bytes.
- **type**:
  - `screencode` or `ascii`: text. It prints as `.text`: `screencode` in Commodore screen codes (64tass's `"screen"` encoding), `ascii` in Commodore ASCII (64tass's `"none"`); as `.null` when sized by `[until $00]` and as `.ptext`, on one line, when sized by `[lengthbyte]`.
  - `byte`, `word`, `long` (24 bits), `dword`.
  - `addr`: a 16-bit address, printed as `.addr` with the label of the address it holds. Code that stores both halves of a constant address into an `addr` (four instructions in a row: an immediate load and a store per half) labels that address and prints the loads as `#<label` and `#>label`.
  - `rta`: a 16-bit address minus one, as an `rts` dispatch table holds it: printed as `.rta` with the label of the address plus one, which is traced as code.
  - `sbyte`, `sword`, `slong`, `sdword`: signed numbers, printed as `.char`, `.sint`, `.lint` and `.dint`, e.g. `.char -3`.
  - `code`: an entry point to trace from; any `[size]` is ignored.

  A range without a type is a placeholder: printed as bytes, but a later, more specific line may narrow part of it without a conflict. A single address without a type only names (or comments) that address and covers no memory, so it can sit inside another line's array or word, e.g. a high score on the screen. Inside an array, a word or an instruction, a label is printed as `label = $addr` after it.
- **size**:
  - `[n]`, the element count, e.g. `byte[8]`. `n` is a number, or `*` and `+` over numbers (`*` binds tighter, no parentheses): `byte[$af]`, `byte[40*21]`, `byte[40*19+5]`. A count of 0 (or a range too short for one element) is an error.
  - `[until n]`: the elements up to and including the first one that holds `n`, e.g. `ascii[until $00]` for a null-terminated string. No such element before memory the binary doesn't load is an error.
  - `[lengthbyte]`, only for one-byte types: a byte holding the number of elements after it, then those elements, e.g. `ascii[lengthbyte]` for a `.ptext` string.
- **label**: a name for the address, from `[A-Za-z0-9._?]`. It can't be a reserved word: `deflower`, `include`, `virtual`, `banked`, `selfmod`, `export`, `screencode`, `ascii`, `byte`, `word`, `long`, `dword`, `addr`, `rta`, `sbyte`, `sword`, `slong`, `sdword`, `code`, `until`, `lengthbyte`, `noreturn`.
- **(parameters)**, only on a code line: the data that follows every `jsr` to this address in memory, which the routine reads and steps over, as a comma-separated list of `<type>[<size>] [<name>]`, e.g. `$2c75 code print_inline (ascii[until $ff] text)`. At each call site the data is registered, the names are printed after the `jsr`, and the tracing carries on after the data. A data line at a call site wins over the list for that call; the tracing then carries on after that line's data.
- **noreturn**, only on a code line: a `jsr` to this address doesn't return, so nothing after the call (or after its parameters) is traced.
- **export `<file>.bin`** or **export `<file>.prg`**: writes the memory the line covers to `out/<file>.bin`, or to `out/<file>.prg` after a 2-byte load address (the region's start), and puts `.binary "<file>.bin"` (or `.binary "<file>.prg", 2`, skipping the load address) there in the output instead of the data. Only for a data line (a range or a type, not code, not virtual) of the `.flo` file itself, not an included one; each file name once per `.flo` file. The region is fixed data: the code tracing stops at it, even without a type, and labels inside it are printed as `label = $addr` after it.
- **{**: opens a block, see [Blocks](#blocks).

Two lines may only cover the same memory if the earlier one is a placeholder (or both say exactly the same); otherwise it's an area conflict, and that run's output isn't written.

### `<address> banked <label>`

A `jsr`, `jmp` or branch target in memory banked in over the binary's RAM when the program goes there, like a KERNAL routine while the RAM under the KERNAL holds the program's data. A jump or call to the address prints the label, and the tracing doesn't follow it; so does an `rta` value. An `.addr` value and an address setup's `#<`, `#>` print it when the RAM has no label on the address itself. The RAM at the address keeps its own lines: a read or write of it prints the RAM's name. A label with the same name at the same address names the same routine: an included one gives way to the other. The KERNAL and BASIC entry points of `c64.flo` are banked lines.

The label is printed as `label = $addr` at the top of the output, with the line's comment and who calls or jumps to it; an included one only when something does. Takes nothing else: no range, type or `virtual`.

A code line of the file itself at the same address wins over an included banked line, and is an error next to one of its own.

```
$ea31 banked kernal_irq
```

### `<address> selfmod <label>`

Names the operand of self-modifying code: the instruction at the address, whose operand bytes another instruction writes or modifies (a branch aside). Such an operand otherwise prints as a number, since it is only what the binary holds, with a comment saying who sets it, and names nothing. With the line it prints the label, plus or minus the distance to the value the binary holds there: `lda voice_1_notes + $1000, y`. The label is one of the `.flo` file's, or a banked name, and gets the cross-reference.

A line that isn't on an instruction with an address operand, or names no label, is an error; one on an instruction that no traced code writes is a warning, as that code may not be found yet. Takes nothing else: no range, type or `virtual`.

```
$c1db selfmod voice_1_notes
```

### Blocks

```
<address> [virtual] {
    ...
}
```

A block: every address inside it, up to the `}` on its own line, is an offset from the opening line's address, e.g. a chip's registers from its base. `virtual` on the opening line makes every line inside virtual. The opening line takes nothing else (no range, type or label) and covers no memory; a comment above it goes onto the base address. Blocks don't nest, and a block must be closed before the next `deflower` line or the end of the file.

```
$d400 virtual {
    $00 word freq1
    $04 byte control1
}
```

### The grammar

The syntax in full, as `src/deflower/flo/flo.ldb` has it (ANTLR 4 notation: `?` optional, `*` any number, `|` or, `name=` names a part, `# name` names an alternative; the upper case rules are the words).

```antlr
grammar Flo;

file        : statement* EOF ;

// One statement per line. A comment attaches to the next annotation line.
statement   : COMMENT? NL                                    # blank
            | 'deflower' image NL                            # deflower
            | 'load' image NL                                # load
            | 'include' file=ID NL                           # include
            | '}' NL                                         # endBlock
            | annotation NL                                  # line
            ;

// A file to load into memory: a .prg at its own address unless 'at' says
// otherwise, a .bin at the 'at' address, a .vsf as a whole.
image       : file=ID ('at' address=number)? ('from' offset=number)?
              ('size' length=number)? ;

annotation  : at=place 'virtual'? 'banked'? 'selfmod'? type=dataType? label=name?
              parameters? 'noreturn'? ('export' exportFile=ID)? '{'? ;

// The words of the 'load' line are only keywords there.
name        : ID | 'load' | 'at' | 'from' | 'size' ;

// A range's end is exclusive.
place       : start=number ('-' end=number)? ;
number      : INT | HEX ;

dataType    : typeName ('[' size? ']')? ;
typeName    : 'screencode' | 'ascii' | 'byte' | 'word' | 'long' | 'dword'
            | 'addr' | 'rta' | 'sbyte' | 'sword' | 'slong' | 'sdword' | 'code' ;
// '*' binds tighter than '+'.
size        : 'until' terminator=number                      # until
            | 'lengthbyte'                                   # lengthByte
            | number (op=('*' | '+') number)*                # count
            ;

// The data after each jsr to a code line's address.
parameters  : '(' parameter (',' parameter)* ')' ;
parameter   : dataType label=name? ;

HEX     : '$' [0-9a-fA-F]+ ;
INT     : [0-9]+ ;
ID      : [A-Za-z0-9._?]+ ;
COMMENT : [;#] ~[\r\n]* ;
NL      : [\r\n]+ ;
WS      : [ \t]+ -> skip ;
```

## The output

`out/<binary>.asm` is 64tass source, all lowercase except labels and comments:
- code, with operands printed as labels where there is one (`label + $offset` inside an array). Targets without a `.flo` label get an automatic one: `lXXXX` for code, `dXXXX` for data, `aXXXX` for other addresses;
- the data, as `.byte`, `.word`, `.long`, `.dword`, `.addr`, `.rta`, `.char`, `.sint`, `.lint`, `.dint`, `.text`, `.null`, `.ptext` and `.binary`, and the placeholders and loaded memory nobody claimed as `.byte`;
- `.virtual` blocks for the virtual areas;
- `*=` at every jump in the addresses;
- labels on memory that isn't loaded, inside an array or inside an instruction as `label = $addr` defines;
- above each label, the instructions that refer to it, named by the routine they are in: `; called by:`, `jumped to by:`, `read by:`, `written by:`, `modified by:`;
- self-modified operands as numbers with `; operand set by <routine>`, unless a `selfmod` line names them;
- an illegal opcode that has the mnemonic and addressing mode of another one, which an assembler picks instead (the legal one, else the lowest), as its bytes with the instruction in a comment: `.byte $eb, $01 ; sbc #$01`. These are `$eb` (`sbc #`), `$2b` (`anc #`) and the extra `nop`s.

Illegal opcodes need 64tass's `-i` (`--6502`) option: `64tass -i -o game.prg out/game.asm`.

The warnings point at suspect spots without stopping the output, as `warning: $addr: text`: a flow into data, into the middle of an instruction or into memory the binary doesn't load, a `jsr` that returns into data, an instruction that runs into another area or past the end of the binary, a jam, a data line on memory the binary doesn't load, and an operand that refers into an `untouched_` or `unused_` range of the skeleton.
