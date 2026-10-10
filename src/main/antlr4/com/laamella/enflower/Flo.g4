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
 * ; text    or    # text
 *     A comment, on a line of its own (not after an annotation). It is
 *     printed above the next annotation line's address in the output;
 *     consecutive comment lines stay together.
 *
 * <address or range> [virtual] [<type>[<size>]] [<label>] [export <id>] [{]
 *     An annotation line, its parts in exactly this order, each at most once:
 *     - address: $hex (either case) or decimal, e.g. $c000, 49152.
 *       range: start-end, with the end EXCLUSIVE ($c006-$c008 is two bytes).
 *       A range sets the element count to whatever fits; a [size] on
 *       the same line is ignored.
 *     - virtual: memory the program uses but doesn't contain (I/O,
 *       zero page, screen). Output as a .virtual reservation, not as data.
 *     - type: char (text), byte, word, dword, addr (a 16-bit address,
 *       printed as .addr with the label of the address it holds), or code
 *       (an entry point to trace from; any [size] is ignored). A range without a type is a
 *       placeholder: printed as bytes, but a later, more specific line
 *       may narrow part of it without a conflict. A single address
 *       without a type only names (or comments) that address and covers
 *       no memory, so it can sit inside another line's array or word,
 *       e.g. a high score on the screen. Inside an array, a word or an
 *       instruction, a label is printed as "label = $addr" after it.
 *     - size: [n], the element count, e.g. byte[8]. n is a number, or *
 *       and + over numbers (* binds tighter, no parentheses): byte[$af],
 *       byte[40*21], byte[40*19+5]. A count of 0 (or a range too short
 *       for one element) is an error.
 *     - label: a name for the address, from [A-Za-z0-9._?]. It can't be
 *       a reserved word: deflower, virtual, export, char, byte, word,
 *       dword, addr, code.
 *     - export <id> parses, but has no effect yet.
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
 *     ; title text, in screen codes
 *     $c100 char[20] title_text
 *     $c000 code start
 */
grammar Flo;
prog:	(statement NEWLINE)* EOF;

statement: COMMENT # comment
    | 'deflower' ID         # setFileName
    | (address | memoryRange) setVirtual? datatype? setLabel? export? OPEN_BLOCK? # line
    | CLOSE_BLOCK                   # endBlock
    ;

address: number;
memoryRange: number '-' number;
setVirtual: 'virtual';
setLabel: ID;
export: 'export' ID;

datatype: (CHAR|BYTE|WORD|DWORD|ADDR|CODE) ( '[' arraySize? ']')?;
// The element count of an array: a number, or * and + over numbers, with
// * binding tighter.
arraySize: arraySize '*' arraySize  # arraySizeMul
    | arraySize '+' arraySize       # arraySizePlus
    | number                        # arraySizeNumber
    ;
number: INT|HEX;

CHAR: 'char';
BYTE: 'byte';
WORD: 'word';
DWORD: 'dword';
ADDR: 'addr';
CODE: 'code';
OPEN_BLOCK: '{';
CLOSE_BLOCK: '}';
COMMENT: (';'| '#')  ~[\r\n]*;
WS: [ \t]+ -> skip;
NEWLINE : [\r\n]+ ;
INT     : [0-9]+ ;
HEX   : '$'[0-9a-fA-F]+;
ID     : [A-Za-z0-9._?]+ ;
