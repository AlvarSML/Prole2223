%{
// Definiciones de variables o regulares
int caracteresBlancos = 0;
int cifrado;

%x COM 
//void convertirMinus(char*);
%}

letra   [a-zA-Z]
digito  [0-9]
digitos ({digito})+
tabulador   \t
blanco [\t\n\r ]
espacio [\t\r ]
mayus [A-Z]
palabra ({letra}|{digito})+

%%
"/*" BEGIN(COM);
<COM>"*/" BEGIN(INITIAL)
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
