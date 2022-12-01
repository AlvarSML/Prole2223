%{
#include <stdio.h>
int yyerror(char *);
%}

%token 
%%

stmtsequence : programstmt  |  programstmt stmtsequence;

programstmt : assigconstruct
            |  loopconstruct
            |  ifconstruct
            |  printstmt;

loopconstruct : WHILE '(' expr ')' stmtsequence ENDWHILE;

ifconstruct : ifthenstmt stmtsequence (elseifconstruct)* (elseconstruct)? ENDIF;

ifthenstmt : IF '(' expr ')' THEN;

elseifconstruct : ELSEIF '(' expr ')' THEN stmtsequence;

elseconstruct : ELSE stmtsequence;

printstmt : PRINT expr (',' expr)*;

assigconstruct: ID '=' expr 
    |  ID '++' 
    |  ID '--';

assigconstruct: ID ('=' expr |'++'|'--' );

expr : expr ('+' | '-' ) multexp | multexp;

multexp : multexp ('*'| '/') value | value;

value : '(' expr ')' | NUM | ID;