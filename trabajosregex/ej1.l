%{
// Definiciones de variables o regulares
int numLinea = 0;
%}

letra   [a-zA-Z]
digito  [0-9]
digitos ({digito})+

%%
 /* parte b */
^{letra}{0,30}\n          {printf("%s","letras |");ECHO;}
 /* parte a */
^.{0,30}\n                {printf("%s","caracters |");ECHO;}
 /* .\n                      {ECHO;} */
%%
 // Rutinas de usuario
int main() {
    yylex();
    return 0;
}