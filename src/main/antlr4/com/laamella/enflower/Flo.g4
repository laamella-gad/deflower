grammar Flo;
prog:	(statement NEWLINE)*;

statement: COMMENT # comment
    | 'deflower' ID         # setFileName
    | expr+ '{'?                # line
    | '}'                           # endBlock
    ;

expr:	expr '*' expr     # mul
    |	expr '+' expr                   # plus
    |	expr '-' expr               # memoryRange
    | expr linetype                 # setSize
    | number                        # address
    | 'system'                      # setSystem
    | 'export' ID                   # export
    | ID                                    # setLabel
    ;

linetype: BYTE|WORD|DWORD|CODE;
number: INT|HEX;

BYTE: 'byte'|'bytes';
WORD: 'word'|'words';
DWORD: 'dword'|'dwords';
CODE: 'code';
COMMENT: (';'| '#')  ~[\r\n]*;
WS: [ \t]+ -> skip;
NEWLINE : [\r\n]+ ;
INT     : [0-9]+ ;
HEX   : '$'[0-9a-fA-F]+;
ID     : [A-Za-z0-9._?]+ ;
