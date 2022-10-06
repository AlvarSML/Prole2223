%{
    /*
    *   Usando flex crear un programa para procesar un documento XML 
    *   realizando las operaciones necesarias para que al finalizar el 
    *   procesado permita mostrar las siguientes estadísticas:
    *       - el número de comentarios.
    *       - el número de elementos vacíos (finalizan sin tener etiquetas 
    *         anidadas ni texto en su interior).
    *       - el nombre de la etiqueta que contiene más atributos y su número.
    *       - el espacio de nombres con valor más largo y su prefijo asociado, 
    *         si es que lo tiene.
    *
    *   El contenido de las secciones CDATA se deben ignorar para todas 
    *   las estadísticas.
    */
    //%option c++

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Creacion de la pila */
typedef struct stack {
    char **items;
    int len;
} stack;
 
stack* stack_new() {
    return calloc(1, sizeof(stack));
}

void add(stack *in, char *val) {
    if (in) {
        in->items = realloc(in->items, (1+in->len) * sizeof(val));
        if (in->items) {
            in->items[in->len] = val; 
            in->len++;
        }
    }
}

/* definiccion de variables */

int nComentarios = 0;
int nVacios = 0;
int maxAtrimutos = 0;

int entradaComentario();
int entradaPInstruction();
int guardarEtiqueta(char* nombre);


%}

%x INICIO PINS COMM CDATA INI_TAG NAMESPACE ATTR ATTR_VAL

letra       [a-zA-Z]
digito      [0-9]
digitos     ({digito})+
tabulador   \t
blanco      [\t\n\r ]
espacio     [\t\r ]
mayus       [A-Z]
palabra     ({letra}|{digito})+

cdata_ini       (<!\[CDATA)
cdata_close     (\]\]>)

pi_ini      (<\?)
pi_close    (\?>)

comm_ini        (<!--)
comm_close      (-->)

apertura_izq    (<)
cierre_derecha  (>)

auto_cierre     (\/{cierre_derecha})
cierre_normal   ({apertura_izq}\/)

tag_ini     ({apertura_izq}|{auto_cierre}){blanco}*
tag_close   {blanco}*((cierre_normal)|{cierre_derecha})

tag_name    ({blanco}*{palabra})
namespace   ({tag_name}:)

attr_val    ((="{palabra}")|(={digitos}))

%%

<INICIO>{cdata_ini}     {BEGIN(CDATA);/*Cosas de cdata*/}
<CDATA>{cdata_close}    {BEGIN(INICIO);/*Fin del cdata*/}

<INICIO>{pi_ini}        {BEGIN(PINS);}
<PINS>{pi_close}        {BEGIN(INICIO);}

<INICIO>{comm_ini}      {entradaComentario();BEGIN(COMM);}

<COMM>{comm_close}      {BEGIN(INICIO);}

<INICIO>{tag_ini}       {BEGIN(INI_TAG);}
<INI_TAG>{tag_name}     {guardarEtiqueta(yytext);BEGIN(ATTR);}
<INI_TAG>{namespace}    {BEGIN(NAMESPACE);/*!Puede estar mal la definicion*/}
<INI_TAG>{tag_close}    {BEGIN(INICIO);}

<NAMESPACE>{tag_name}   {BEGIN(ATTR);}

<ATTR>{attr_val}        {BEGIN(ATTR_VAL);}
<ATTR_VAL>{tag_close}   {BEGIN(INICIO);}



.|\n {ECHO;}

%%
int entradaComentario() {
    nComentarios++;
    printf("[COMM]-> Procesando %d comentaro \n",nComentarios);
    return 0;
}

int entradaPInstruction() {
    printf("[PINS]-> Entrado en una instruccion de Procesado");
    return 0;
}



int guardarEtiqueta(char* nombre){

}

int main( int argc, char **argv ){
    ++argv, --argc;	/* skip over program name */
    int prueba = 0;

	if ( argc > 0 )
	    yyin = fopen( argv[0], "r" );
	else
	    yyin = stdin;
    
    stack* tagStack = stack_new();
    BEGIN(INICIO);
	yylex();
}
