%{
// Definiciones de variables o regulares
int numLineaBlanco = 0;
%}

letra   [a-zA-Z]
digito  [0-9]
digitos ({digito})+

%%
^\n     {numLineaBlanco++;}
%%
 // Rutinas de usuario
int main() {
    yylex();
    printf("%i \n",numLineaBlanco);
    return 0;
}