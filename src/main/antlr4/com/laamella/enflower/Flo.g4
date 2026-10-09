grammar Flo;
prog:	(statement NEWLINE)*;

statement: COMMENT # comment
    | 'deflower' ID         # setFileName
    | expr+ '{'?                # line
    | '}'                           # endBlock
    ;

expr:	number '-' number               # memoryRange
    | expr datatype                 # setSize
    | number                        # address
    | 'virtual'                     # setVirtual
    | 'export' ID                   # export
    | ID                                    # setLabel
    ;

datatype: (CHAR|BYTE|WORD|DWORD|CODE) ( '[' arraySize? ']')?;
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
CODE: 'code';
COMMENT: (';'| '#')  ~[\r\n]*;
WS: [ \t]+ -> skip;
NEWLINE : [\r\n]+ ;
INT     : [0-9]+ ;
HEX   : '$'[0-9a-fA-F]+;
ID     : [A-Za-z0-9._?]+ ;
