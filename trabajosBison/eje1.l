%{
#include "y.tab.h"
int yydebug = 1;
%}
%%

[0-9]+ { 
   yylval=atoi(yytext); 
   return NUM; 
}

.	return yytext[0];
