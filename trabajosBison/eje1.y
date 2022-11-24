%{
#include <stdio.h>
int yyerror(char *);
%}
%token NUM

%%
axioma: exp  { printf("=%d\n", $1); }; 
exp: exp '+' term { $$=$1+$3; }
     | exp '-' term {$$=$1-$3; }
     | term	{ $$=$1; }
     ;
term: term '*' fac {$$=$1*$3; }
     | fac	{ $$=$1; }
     ;
fac: NUM	{ $$=$1; }
     | '(' exp ')'	{ $$=$2; } 
     ;
%%
int yyerror(char *s){printf("%s\n",s);}
int main(){ yyparse(); }

