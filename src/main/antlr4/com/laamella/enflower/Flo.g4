/*
 * The .flo format: how to disassemble one or more 6502 memory images.
 * One statement per line; blank lines and indentation are ignored.
 *
 * deflower <file>
 *     Starts a run: loads a .vsf VICE snapshot or a .prg (2-byte load
 *     address, then bytes), relative to the .flo file's directory. The
 *     lines after it, up to the next 'deflower' line, annotate that image,
 *     and its output is out/<file without extension>.asm. Must come
 *     before any annotation line.
 *
 * include <file>
 *     Reads the lines of another .flo file into the current run, e.g. a
 *     machine's I/O registers and ROM routines. The file is looked up
 *     relative to the including file; when there is none, a file built
 *     into Deflower is used: c64.flo (all of the C64 pieces below, the
 *     view with $01 = $37), c64_zeropage.flo, c64_system.flo ($0100-$0800:
 *     stack, KERNAL workspace and vectors, screen), c64_io.flo,
 *     c64_basic.flo and c64_kernal.flo. Included files may include others,
 *     but can't contain 'deflower' lines.
 *     A VICE snapshot holds the RAM only, not the ROMs or I/O banked over
 *     it, so without these lines a jump into the KERNAL traces the RAM
 *     underneath. Include the pieces the program has banked in.
 *     Included lines are weak: any line of the including file that covers
 *     the same memory or names the same address wins, whatever the order,
 *     and an included element it overlaps is dropped. Included areas still
 *     stop the code tracing. Included virtual areas and included labels
 *     on memory no area covers are only printed when an instruction's
 *     operand or an .addr value refers to them.
 *
 * ; text    or    # text
 *     A comment, on a line of its own (not after an annotation). It is
 *     printed above the next annotation line's address in the output;
 *     consecutive comment lines stay together.
 *
 * <address or range> [virtual] [<type>[<size>]] [<label>] [(<parameters>)] [noreturn] [export <id>] [{]
 *     An annotation line, its parts in exactly this order, each at most once:
 *     - address: $hex (either case) or decimal, e.g. $c000, 49152.
 *       range: start-end, with the end EXCLUSIVE ($c006-$c008 is two bytes).
 *       A range sets the element count to whatever fits; a [size] on
 *       the same line is ignored.
 *     - virtual: memory the program uses but doesn't contain (I/O,
 *       zero page, screen). Output as a .virtual reservation, not as data.
 *       A data element on memory the image doesn't load is made virtual
 *       anyway, with a warning, so it isn't printed as zero bytes.
 *     - type: screencode or ascii (text), byte, word, long (24
 *       bits), dword, addr (a 16-bit address, printed as .addr with the
 *       label of the address it holds), rta (a 16-bit address minus one,
 *       as an rts dispatch table holds it: printed as .rta with the label
 *       of the address plus one, which is traced as code), sbyte, sword,
 *       slong, sdword
 *       (signed numbers, printed as .char, .sint, .lint and .dint, e.g.
 *       .char -3), or code (an entry point to trace from; any [size] is
 *       ignored). Text prints as .text: screencode in Commodore screen
 *       codes (64tass's "screen" encoding), ascii in Commodore ASCII
 *       (64tass's "none"); as .null when sized by [until $00] and as
 *       .ptext, on one line, when sized by [lengthbyte]. Code that stores
 *       both halves of a constant address into an addr (four
 *       instructions in a row: an immediate load and a store per half)
 *       labels that address and prints the loads as #<label and #>label.
 *       A range without
 *       a type is a
 *       placeholder: printed as bytes, but a later, more specific line
 *       may narrow part of it without a conflict. A single address
 *       without a type only names (or comments) that address and covers
 *       no memory, so it can sit inside another line's array or word,
 *       e.g. a high score on the screen. Inside an array, a word or an
 *       instruction, a label is printed as "label = $addr" after it.
 *     - size: [n], the element count, e.g. byte[8]. n is a number, or *
 *       and + over numbers (* binds tighter, no parentheses): byte[$af],
 *       byte[40*21], byte[40*19+5]. A count of 0 (or a range too short
 *       for one element) is an error. Or [until n]: the elements up to and
 *       including the first one that holds n, e.g. ascii[until $00] for a
 *       null-terminated string. No such element before memory the image
 *       doesn't load is an error. Or [lengthbyte], only for one-byte
 *       types: a byte holding the number of elements after it, then those
 *       elements, e.g. ascii[lengthbyte] for a .ptext string.
 *     - label: a name for the address, from [A-Za-z0-9._?]. It can't be
 *       a reserved word: deflower, include, virtual, export,
 *       screencode, ascii, byte, word, long, dword, addr, rta, sbyte, sword,
 *       slong, sdword, code, until, lengthbyte, noreturn.
 *     - (parameters), only on a code line: the data that follows every
 *       jsr to this address in memory, which the routine reads and steps
 *       over, as a comma-separated list of <type>[<size>] [<name>], e.g.
 *       $2c75 code print_inline (ascii[until $ff] text). At each call site
 *       the data is registered, the names are printed after the jsr, and
 *       the tracing carries on after the data. A data line at a call site
 *       wins over the list for that call; the tracing then carries on
 *       after that line's data.
 *     - noreturn, only on a code line: a jsr to this address doesn't
 *       return, so nothing after the call (or after its parameters) is
 *       traced.
 *     - export <file>.bin or export <file>.prg: writes the memory the
 *       line covers to out/<file>.bin, or to out/<file>.prg after a
 *       2-byte load address (the region's start), and puts
 *       '.binary "<file>.bin"' (or '.binary "<file>.prg", 2', skipping
 *       the load address) there in the output instead of the data. Only for a data line (a range or a
 *       type, not code, not virtual) from the .flo file itself, not an
 *       included one; each file name once per .flo file. The region is
 *       fixed data: the code tracing stops at it, even without a type,
 *       and labels inside it are printed as "label = $addr" after it.
 *     Two lines may only cover the same memory if the earlier one is a
 *     placeholder (or both say exactly the same); otherwise it's an area
 *     conflict, and that run's output isn't written.
 *
 * <address> [virtual] {
 *     ...
 * }
 *     A block: every address inside it, up to the '}' on its own line, is
 *     an offset from the opening line's address, e.g. a chip's registers
 *     from its base. 'virtual' on the opening line makes every line inside
 *     virtual. The opening line takes nothing else (no range, type or
 *     label) and covers no memory; a comment above it goes onto the base
 *     address. Blocks don't nest, and a block must be closed before the
 *     next 'deflower' line or the end of the file.
 *         $d400 virtual {
 *             $00 word freq1
 *             $04 byte control1
 *         }
 *
 * Example:
 *     deflower game.prg
 *     $d020 virtual byte border_color
 *     $c100 screencode[20] title_text
 *     $c000 code start
 */
grammar Flo;
prog:	(statement NEWLINE)* EOF;

statement: COMMENT # comment
    | 'deflower' ID         # setFileName
    | 'include' ID          # include
    | (address | memoryRange) setVirtual? datatype? setLabel? parameters? noReturn? export? OPEN_BLOCK? # line
    | CLOSE_BLOCK                   # endBlock
    ;

address: number;
memoryRange: number '-' number;
setVirtual: 'virtual';
setLabel: ID;
export: 'export' ID;
parameters: '(' parameter (',' parameter)* ')';
parameter: datatype ID?;
noReturn: 'noreturn';

datatype: (SCREENCODE|ASCII|BYTE|WORD|LONG|DWORD|ADDR|RTA|SBYTE|SWORD|SLONG|SDWORD|CODE) ( '[' (arraySize | untilSize | lengthByte)? ']')?;
// The elements up to and including the first one that equals the number.
untilSize: 'until' number;
// A length byte, then that many elements.
lengthByte: 'lengthbyte';
// The element count of an array: a number, or * and + over numbers, with
// * binding tighter.
arraySize: arraySize '*' arraySize  # arraySizeMul
    | arraySize '+' arraySize       # arraySizePlus
    | number                        # arraySizeNumber
    ;
number: INT|HEX;

SCREENCODE: 'screencode';
ASCII: 'ascii';
BYTE: 'byte';
WORD: 'word';
LONG: 'long';
DWORD: 'dword';
ADDR: 'addr';
RTA: 'rta';
SBYTE: 'sbyte';
SWORD: 'sword';
SLONG: 'slong';
SDWORD: 'sdword';
CODE: 'code';
OPEN_BLOCK: '{';
CLOSE_BLOCK: '}';
COMMENT: (';'| '#')  ~[\r\n]*;
WS: [ \t]+ -> skip;
NEWLINE : [\r\n]+ ;
INT     : [0-9]+ ;
HEX   : '$'[0-9a-fA-F]+;
ID     : [A-Za-z0-9._?]+ ;
