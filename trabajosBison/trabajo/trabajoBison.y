%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define YYERROR_VERBOSE 1

int yyerror(char *);

int getNextNumber()
{
   static int nextNumber=-1;
   return ++nextNumber;
}

FILE *yyin;
%}

 /* Numero y etiqueta tienen el mismo tipo para mejorar la legibilidad */

%union {
    int numero;
    int etiqueta;  
    char* string;    
}

%start stmtsequence
%token IF THEN ELSEIF ELSE WHILE ENDWHILE ENDIF INCREMENTO DECREMENTO PRINT ASIGNA MAS MENOS POR ENTRE OPAR CPAR
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

loopconstruct: 
    WHILE {$<etiqueta>$ = getNextNumber(); printf("LBL%d\n",$<etiqueta>$);}
    OPAR
    expr 
    CPAR { $<etiqueta>$ = getNextNumber(); printf("\t # sifalso vea LBL%d\n",$<etiqueta>$); }
    stmtsequence
    ENDWHILE {printf("\t # vea LBL%d\n",$<etiqueta>2);printf("LBL %d\n",$<etiqueta>6);}
    ;

/* cambiado para quitar los * y ? */
ifconstruct: 
    ifthenstmt 
    { 
        $<etiqueta>$ = getNextNumber(); // etiqueta del siguiente else/elsif
        printf("\t # sifalso vea LBL%d\n",$<etiqueta>$); 
    }
    stmtsequence 
    { 
        $<etiqueta>$ = getNextNumber(); // etiqueta del final
        printf("\t # vea LBL%d\n",$<etiqueta>$); 
        printf("LBL %d\n",$<etiqueta>2);
    }
    { 
        $<etiqueta>$ = $<etiqueta>4; // se fija en el tope de pila para poder ser accedido por el primer elseif
    }
    elseifconstruct 
    elseconstruct
    ENDIF { printf("Finif LBL%d\n",$<etiqueta>4); }
    ;

ifthenstmt:
    IF 
    OPAR
    expr
    CPAR
    THEN
    ;

/* elseif: ELSEIF(expr) THEN stmt elseiffinal */
elseifconstruct:
    { 
        $<etiqueta>$ = $<etiqueta>0;
    }
    {$<etiqueta>$ = getNextNumber();} /*Se obtiene el siguiente elseif -6 */
    ELSEIF // -5
    OPAR // -4
    expr // -3
    CPAR // -2
    THEN // -1
    { printf("\t # sifalso vea LBL%d\n",$<etiqueta>2); } // 
    stmtsequence // 0
    { printf("\t # vea fin LBL%d\n",$<etiqueta>1); 
    printf("Elseif LBL%d\n",$<etiqueta>2); }
    { $<etiqueta>$ = $<etiqueta>1;}
    elseiffinal    
    ;

elseiffinal:
    | { 
        $<etiqueta>$ = $<etiqueta>0;
    } 
       elseifconstruct
    ;

/* Eliminado *
* elseif: (elseseq | ε)
* elseseq: ELSE stmtsequence
*/
elseconstruct:
    elseseq
    | 
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
    ID { printf("\t # valori %s\n" , $<string>1 ); }
    assignopts 
    ;

assignopts:
    ASIGNA 
    expr { printf("\t # asigna\n"); }
    | INCREMENTO { printf("\t # mete 1\n\t # valord %s\n\t # suma \n\t # asinga\n",$<string>-1); }
    | DECREMENTO { printf("\t # mete 1\n\t # valord %s\n\t # resta \n\t # asinga\n",$<string>-1); }
    | error
    ;
/*
* expr: expr expropts multexpr
* expropts: + | -
*/
expr:
    expr MAS multexp { printf("\t # suma \n"); }
    | expr MENOS multexp { printf("\t # resta \n"); }
    | multexp
    ;
/*
* multexpr: multexpr multexpropts value | value
* multexpr opts: * | /
*/
multexp:
    multexp POR value { printf("\t # multi \n"); }
    | multexp ENTRE value { printf("\t # div \n"); }
    | value 
    ;

value:
    OPAR expr CPAR
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