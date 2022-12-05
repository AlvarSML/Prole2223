%{
#include <stdio.h>
#include <stdlib.h>

int yyerror(char *);

FILE *yyin;
%}

%union {
    int numero;
    char* string;
}

%start stmtsequence
%token IF THEN ELSEIF ELSE WHILE ENDWHILE ENDIF INCREMENTO DECREMENTO PRINT
%token <string> ID
%token <numero> NUM

%left '+' '-'
%left '*'
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
    stmtsequence 
    elseiffinal
    ;

elseiffinal:
    elseifconstruct
    | /* vacío */
    ;

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
    stmtsequence 
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
    ID { printf("\t valori %d\n" , $1 ); }
    assignopts 
    ;

assignopts:
    '=' expr 
    | INCREMENTO
    | DECREMENTO

/*
*
*/
expr:
    expr '+' multexp
    expr '-' multexp
    | multexp
    ;

multexp:
    multexp '*' value
    | multexp '/' value
    | value
    ;

value:
    '(' expr ')'
    | NUM
    | ID;

%%

int yyerror(char *s){printf("%s\n",s);}

int main( int argc, char **argv ){
    ++argv, --argc;	/* skip over program name */
    int prueba = 0;

	if ( argc > 0 )
	    yyin = fopen( argv[0], "r" );
	else
	    yyin = stdin;
    
    yyparse();
}