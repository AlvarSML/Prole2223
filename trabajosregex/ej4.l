%{
// Definiciones de variables o regulares
int caracteresBlancos = 0;
//void convertirMinus(char*);
%}

letra   [a-zA-Z]
digito  [0-9]
digitos ({digito})+
espacio     \ 
tabulador   \t
blanco [\t\n\r ]
mayus [A-Z]

%%
{mayus}{1}    {convertirMinus(yytext);}

    /* .|\n {;} */
%%
 // Rutinas de usuario
int main() {
    yylex();
    return 0;
}

void convertirMinus(char* caracter){
    char min = *caracter + 32;
    printf("%s",&min);
}