%{
// Definiciones de variables o regulares
int caracteresBlancos = 0;
%}

letra   [a-zA-Z]
digito  [0-9]
digitos ({digito})+
espacio     \ 
tabulador   \t
blanco [\t\n\r ]

%%
{blanco} {caracteresBlancos++;}
.|\n {;}
%%
 // Rutinas de usuario
int main() {
    yylex();
    printf("%i \n",caracteresBlancos);
    return 0;
}