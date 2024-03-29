%{
#include <stdio.h>
int yyerror(char *);
%}
%union {
  int p;
  int i;
}
%token <p> NP
%token <i> NI
%type <p> noterm
%%
axioma: NP NI noterm NP ;
noterm: NP NI { 
   printf("%d %d %d %d\n",
	$<p>-1,$<i>0,$1,$2); 
	} ;
%%
int yyerror(char *s){printf("%s\n",s);}
int main(){ yyparse(); }

