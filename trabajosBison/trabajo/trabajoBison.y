%{
#include <stdio.h>
int yyerror(char *);
%}

%token IF THEN ELSEIF ELSE WHILE DO ENDIF
%%

stmtsequence:
    programstmt  
    |  programstmt stmtsequence
    ;

programstmt: 
    assigconstruct
    |  loopconstruct
    |  ifconstruct
    |  printstmt;

loopconstruct: WHILE
    '('
    expr
    ')'
    stmtsequence
    ENDWHILE
    ;

/* cambiado para quitar los * y ? */
ifconstruct: 
    ifthenstmt 
    stmtsequence 
    elseifconstruct
    elseconstruct
    ENDIF
    ;

ifthenstmt:
    IF
    '('
    expr
    ')'
    THEN
    ;

/* elseif: ELSEIF(expr) THEN stmt elseiffinal */
elseifconstruct:
    ELSEIF
    '('
    expr
    ')'
    THEN
    stmtsequence {}
    elseiffinal
    ;

elseiffinal:
    elseifconstruct
    | /* vacío */
    :

/* Eliminado *
* elseif: (elseseq | ε)
* elseseq: ELSE stmtsequence
*/
elseconstruct:
    elseseq
    | /* vacío */ 
    ;

elseseq:
    ELSE
    stmtsequence {}
    ;

/* Eliminado *
* printstmt: PRINT expr printexprs
* printexprs: "," expr | ε
*/
printstmt:
    PRINT
    expr
    printexprs
    ;

printexprs:
    ',' expr
    | /* vacio */
    ;

/*
* assigconstruct: ID assignopts
* assignopts: "=" expr | "++" | "--"
*/
assigconstruct: 
    ID
    assignopts
    ;

assignopts:
    "=" expr 
    | "++" 
    | "--"

/*
*
*/
expr:
    expr "+" multexp
    expr "-" multexp
    | multexp
    ;

multexp:
    multexp "*" value
    | multexp "/" value
    | value
    ;

value:
    '(' expr ')'
    | NUM
    | ID;