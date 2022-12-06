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
%token IF THEN ELSEIF ELSE WHILE ENDWHILE ENDIF INCREMENTO DECREMENTO PRINT ASIGNA MAS MENOS POR ENTRE
%token <string> ID
%token <numero> NUM
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
    ID 
    assignopts { printf("\t # valori %s\n" , $<string>1 ); }
    ;

assignopts:
    ASIGNA { printf("\t # asigna\n"); }
    expr 
    | INCREMENTO
    | DECREMENTO

/*
* expr: expr expropts multexpr
* expropts: + | -
*/
expr:
    expr expropts multexp
    | multexp
    ;

expropts:
    MAS
    | MENOS

/*
* multexpr: 
* multexpr opts:
*/
multexp:
    multexp POR value
    | multexp ENTRE value
    | value 
    ;

multexpropts:
    POR
    | ENTRE
    ;

value:
    '(' expr ')'
    | NUM { printf("\t # mete %d\n", $<numero>1); }
    | ID  { printf("\t # valord %s\n", $<string>1); }
    ;

%%

int yyerror(char *s){
    extern int yylineno;
    extern char *yytext;

    fprintf(stderr, "%s en la linea %d cerca de: <%s>\n", s, yylineno, yytext);
    exit(-1);

    }

int main( int argc, char **argv ){
    ++argv, --argc;	/* skip over program name */
    int prueba = 0;

	if ( argc > 0 )
	    yyin = fopen( argv[0], "r" );
	else
	    yyin = stdin;
    
    yyparse();
}