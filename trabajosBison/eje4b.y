%{
#include <stdio.h>
#include <stdlib.h>
int yyerror(char *);
%}
%token NUM
%left '+' '-'
%left '*'
%%
command: exp ;
exp: exp '+' exp | exp '-' exp | exp '*' exp | '(' exp ')' | NUM;
%%
int yyerror(char *s){printf("%s\n",s);}
int main(){ yyparse(); }

