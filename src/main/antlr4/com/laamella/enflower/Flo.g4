grammar Flo;
prog:	(statement NEWLINE)*;

// TODO add comments to disassembly
statement: COMMENT # comment
    | 'deflower' ID         # setFileName
    | expr+ '{'?                # line
    | '}'                           # endBlock
    ;

expr:	number '*' number     # mul
    |	number '+' number                   # plus
    |	number '-' number               # memoryRange
    | expr datatype                 # setSize
    | number                        # address
    | 'system'                      # setSystem
    | 'export' ID                   # export
    | ID                                    # setLabel
    ;

datatype: (CHAR|BYTE|WORD|DWORD|CODE) ( '[' arraySize=INT? ']')?;
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
