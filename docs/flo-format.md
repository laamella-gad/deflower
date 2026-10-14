# The .flo format

A `.flo` file says how to disassemble one or more 6502 memory images. One statement per line; blank lines and indentation are ignored.

## `deflower <file>`

Starts a run: loads a `.vsf` VICE snapshot or a `.prg` (2-byte load address, then bytes), relative to the `.flo` file's directory. The lines after it, up to the next `deflower` line, annotate that image, and its output is `out/<file without extension>.asm`. Must come before any annotation line.

## `include <file>`

Reads the lines of another `.flo` file into the current run, e.g. a machine's I/O registers and ROM routines. The file is looked up relative to the including file; when there is none, a file built into Deflower is used:
- `c64.flo`: all of the C64 pieces below, the view with `$01 = $37`;
- `c64_zeropage.flo`;
- `c64_system.flo`: `$0100-$0800`, the stack, KERNAL workspace and vectors, the screen;
- `c64_io.flo`;
- `c64_basic.flo`;
- `c64_kernal.flo`.

Included files may include others, but can't contain `deflower` lines.

A VICE snapshot holds the RAM only, not the ROMs or I/O banked over it, so without these lines a jump into the KERNAL traces the RAM underneath. Include the pieces the program has banked in.

Included lines are weak: any line of the including file that covers the same memory or names the same address wins, whatever the order, and an included element it overlaps is dropped. Included areas still stop the code tracing. Included virtual areas and included labels on memory no area covers are only printed when an instruction's operand or an `.addr` value refers to them.

## `; text` or `# text`

A comment, on a line of its own (not after an annotation). It is printed above the next annotation line's address in the output; consecutive comment lines stay together.

## Annotation lines

```
<address or range> [virtual] [<type>[<size>]] [<label>] [(<parameters>)] [noreturn] [export <id>] [{]
```

The parts come in exactly this order, each at most once:

- **address**: `$hex` (either case) or decimal, e.g. `$c000`, `49152`.
  **range**: `start-end`, with the end EXCLUSIVE (`$c006-$c008` is two bytes). A range sets the element count to whatever fits; a `[size]` on the same line is ignored.
- **virtual**: memory the program uses but doesn't contain (I/O, zero page, screen). Output as a `.virtual` reservation, not as data. A data element on memory the image doesn't load is made virtual anyway, with a warning, so it isn't printed as zero bytes.
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
  - `[until n]`: the elements up to and including the first one that holds `n`, e.g. `ascii[until $00]` for a null-terminated string. No such element before memory the image doesn't load is an error.
  - `[lengthbyte]`, only for one-byte types: a byte holding the number of elements after it, then those elements, e.g. `ascii[lengthbyte]` for a `.ptext` string.
- **label**: a name for the address, from `[A-Za-z0-9._?]`. It can't be a reserved word: `deflower`, `include`, `virtual`, `banked`, `selfmod`, `export`, `screencode`, `ascii`, `byte`, `word`, `long`, `dword`, `addr`, `rta`, `sbyte`, `sword`, `slong`, `sdword`, `code`, `until`, `lengthbyte`, `noreturn`.
- **(parameters)**, only on a code line: the data that follows every `jsr` to this address in memory, which the routine reads and steps over, as a comma-separated list of `<type>[<size>] [<name>]`, e.g. `$2c75 code print_inline (ascii[until $ff] text)`. At each call site the data is registered, the names are printed after the `jsr`, and the tracing carries on after the data. A data line at a call site wins over the list for that call; the tracing then carries on after that line's data.
- **noreturn**, only on a code line: a `jsr` to this address doesn't return, so nothing after the call (or after its parameters) is traced.
- **export `<file>.bin`** or **export `<file>.prg`**: writes the memory the line covers to `out/<file>.bin`, or to `out/<file>.prg` after a 2-byte load address (the region's start), and puts `.binary "<file>.bin"` (or `.binary "<file>.prg", 2`, skipping the load address) there in the output instead of the data. Only for a data line (a range or a type, not code, not virtual) from the `.flo` file itself, not an included one; each file name once per `.flo` file. The region is fixed data: the code tracing stops at it, even without a type, and labels inside it are printed as `label = $addr` after it.

Two lines may only cover the same memory if the earlier one is a placeholder (or both say exactly the same); otherwise it's an area conflict, and that run's output isn't written.

## `<address> banked <label>`

A `jsr`, `jmp` or branch target in memory banked in over the image's RAM when the program goes there, like a KERNAL routine while the RAM under the KERNAL holds the program's data. A jump or call to the address prints the label, and the tracing doesn't follow it; so does an `rta` value. An `.addr` value and an address setup's `#<`, `#>` print it when the RAM has no label on the address itself. The RAM at the address keeps its own lines: a read or write of it prints the RAM's name. A label with the same name at the same address names the same routine: an included one gives way to the other. The KERNAL and BASIC entry points of `c64.flo` are banked lines.

The label is printed as `label = $addr` at the top of the output, with the line's comment and who calls or jumps to it; an included one only when something does. Takes nothing else: no range, type or `virtual`.

A code line of the file itself at the same address wins over an included banked line, and is an error next to one of its own.

```
$ea31 banked kernal_irq
```

## `<address> selfmod <label>`

Names the operand of self-modifying code: the instruction at the address, whose operand bytes another instruction writes or modifies (a branch aside). Such an operand otherwise prints as a number, since it is only what the image holds, with a comment saying who sets it, and names nothing. With the line it prints the label, plus or minus the distance to the value the image holds there: `lda voice_1_notes + $1000, y`. The label is one of the `.flo` file's, or a banked name, and gets the cross-reference.

A line that isn't on an instruction with an address operand, or names no label, is an error; one on an instruction that no traced code writes is a warning, as that code may not be found yet. Takes nothing else: no range, type or `virtual`.

```
$c1db selfmod voice_1_notes
```

## Blocks

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

## Example

```
deflower game.prg
$d020 virtual byte border_color
$c100 screencode[20] title_text
$c000 code start
```

## Errors

A line that doesn't fit the format stops the whole file: "Failed to parse <file>:", then one `line N: expected <parts>, found <token>` per bad line, for its first problem, naming the parts as this document does, or `unexpected '<character>'` for a character no word holds.
