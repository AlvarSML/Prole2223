
%{
#include "y.tab.h"
#include <string.h>
int yydebug = 1;
%}

letra       [a-zA-Z]
digito      [0-9]
digitos     ({digito})+
simbolo    [\_]
tabulador   \t
blanco      [\t\n\r ]
espacio     [\t\r ]
mayus       [A-Z]
palabra     (({letra}|{simbolo})({letra}|{digito}|{simbolo})*)
texto       (([^"'])*)

identificador (({letra}|\_)({letra}|{digito}|{simbolo})*)

%%

"if" {return IF;}
"then" {return THEN;}
"elseif" {return ELSEIF;}
"else" {return ELSE;}
"endif" {return ENDIF;}
"while" {return WHILE;}
"endwhile" {return ENDWHILE;}
"++" {return INCREMENTO;}
"--" {return DECREMENTO;}
"print" {return PRINT;}
"=" {return ASIGNA;}
"+" {return MAS;}
"-" {return MENOS;}
"*" {return POR;}
"/" {return ENTRE;}
"(" {return OPAR;}
")" {return CPAR;}
{digitos} {yylval.numero = atoi(yytext); return NUM;}
{identificador} {yylval.string = strdup(yytext); return ID;}
[ \t\r\n] ;
%%

