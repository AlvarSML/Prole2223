
 /* the "incl" state is used for picking up the name
 * of an include file
 */
%x incl

letra   [a-zA-Z]
digito  [0-9]
digitos ({digito})+
tabulador   \t
blanco [\t\n\r ]
espacio [\t\r ]
mayus [A-Z]
palabra ({letra}|{digito})+

%{
int numLinea = 0;
#define MAX_INCLUDE_DEPTH 10
    YY_BUFFER_STATE include_stack[MAX_INCLUDE_DEPTH];
    int include_stack_ptr = 0;
%}

%%

{palabra}({espacio})*\n    {printWord(yytext);}
^{espacio}*{palabra}{1}     {printWord(yytext);}
.|\n {;}

%%
 // Rutinas de usuario
int main() {
    yylex();
    return 0;
}

printWord(char* text){
    printf("Palabra: %s ",text);
}
