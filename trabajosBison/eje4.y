%{
#include <stdio.h>
int yyerror(char *);
%}
%token NUM

%%
command: exp ;
exp: exp '+' exp | exp '-' exp | exp '*' exp | '(' exp ')' | NUM;
%%
int yyerror(char *s){printf("%s\n",s);}
int main(){ yyparse(); }

