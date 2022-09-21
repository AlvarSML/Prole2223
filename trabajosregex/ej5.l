%{
// Definiciones de variables o regulares
int caracteresBlancos = 0;
int cifrado;
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
{letra}    {convertirMinus(yytext);}

    /* .|\n {;} */
%%
 // Rutinas de usuario
int main() {
    perguntaCesar();
    yylex();
    return 0;
}

void convertirMinus(char* caracter){
    char min = *caracter + cifrado;
    printf("%s",&min);
}

int perguntaCesar(){
    printf("Desplazamiento: ");
    scanf("%d", &cifrado);
    return 0;
}   