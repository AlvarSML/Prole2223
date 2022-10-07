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

#define RESET   "\033[0m"
#define BLACK   "\033[30m"      /* Black */
#define RED     "\033[31m"      /* Red */
#define GREEN   "\033[32m"      /* Green */
#define YELLOW  "\033[33m"      /* Yellow */
#define BLUE    "\033[34m"      /* Blue */
#define MAGENTA "\033[35m"      /* Magenta */
#define CYAN    "\033[36m"      /* Cyan */
#define WHITE   "\033[37m"      /* White */
#define BOLDBLACK   "\033[1m\033[30m"      /* Bold Black */
#define BOLDRED     "\033[1m\033[31m"      /* Bold Red */
#define BOLDGREEN   "\033[1m\033[32m"      /* Bold Green */
#define BOLDYELLOW  "\033[1m\033[33m"      /* Bold Yellow */
#define BOLDBLUE    "\033[1m\033[34m"      /* Bold Blue */
#define BOLDMAGENTA "\033[1m\033[35m"      /* Bold Magenta */
#define BOLDCYAN    "\033[1m\033[36m"      /* Bold Cyan */
#define BOLDWHITE   "\033[1m\033[37m"      /* Bold White */

/* definiccion de variables */

int nComentarios = 0;
int nVacios = 0;

char* etiquetaMaxAttr;
char* etiquetaActual;

char* attrActual;
char* attrValActual;

char* etiquetaActualcompleta;

// No se si usarla
char** arrAtributos;

int maxAtributos = 0;
// Atributos de la etiqueta actual
int nAttrs = 0;

int pins = 0;
int lineasVacias = 0;

int entradaComentario();
int entradaPInstruction();
int guardarEtiqueta(char* nombre);
int mostrarResultados();
int transicionNombreAtributo(char* nombreAtributo);
int transicionValorAtributo(char* valorAtributo);
int transicionCierreEtiqueta();

%}

%x INICIO PINS COMM CDATA INI_TAG TAG_NAME NAMESPACE ATTR ATTR_VAL

letra       [a-zA-Z]
digito      [0-9]
digitos     ({digito})+
simbolo    [\_\-]
tabulador   \t
blanco      [\t\n\r ]
espacio     [\t\r ]
mayus       [A-Z]
palabra     (({letra}|{simbolo})({letra}|{digito}|{simbolo})*)
texto       (([^"'])*)

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

attr_name   ([a-zA-Z\-\_][a-zA-Z0-9]*)
attr_val    (=["']{texto}["'])
attr_namespace ({palabra}:{palabra})

%%

<INICIO>{cdata_ini}     {BEGIN(CDATA);/*Cosas de cdata*/}
<CDATA>{cdata_close}    {BEGIN(INICIO);/*Fin del cdata*/}

<INICIO>{pi_ini}        {entradaPInstruction();BEGIN(PINS);}
<PINS>{pi_close}        {BEGIN(INICIO);}

<INICIO>{comm_ini}      {entradaComentario();BEGIN(COMM);}

<COMM>{comm_close}      {BEGIN(INICIO);}

<INICIO>{tag_ini}       {BEGIN(INI_TAG);}
<INI_TAG>{tag_name}     {guardarEtiqueta(yytext);BEGIN(TAG_NAME);}
<INI_TAG>{namespace}    {BEGIN(NAMESPACE);/*!Puede estar mal la definicion*/}
<INI_TAG>{tag_close}    {transicionCierreEtiqueta();/* La etiqueta se cierra sin atributos */}

<NAMESPACE>{tag_name}   {BEGIN(ATTR);}

<TAG_NAME>{attr_name}   {transicionNombreAtributo(yytext);}

<ATTR>{attr_val}        {transicionValorAtributo(yytext); /* Despues de una atributo siempre hay un valor */ }
<ATTR>{blanco}+         {;/*Ignoramos espacios en blanco*/}
<ATTR_VAL>{tag_close}   {transicionCierreEtiqueta(); /* Cuando despues de un atributo se cierra la etiqueta */}
<ATTR_VAL>{attr_name}   {transicionNombreAtributo(yytext); /* cuando despues de un atributo hay otro*/}



.|\n {;}

%%

int entradaComentario() {
    nComentarios++;
    printf("[COMM]-> Procesando %d comentaro \n",nComentarios);
    return 0;
}

int entradaPInstruction() {
    pins++;
    printf("[PINS]-> Entrado en una instruccion de Procesado \n");
    return 0;
}

int guardarEtiqueta(char* nombre){
    nAttrs = 0;
    etiquetaActual = strdup(nombre);
    printf("%s\n[<TAG]->%s %s La etiqueta actual es \"%s\" %s\n",BOLDRED,RESET,RED,etiquetaActual,RESET);
    return 0;

}

/**
*   @brief Funcion para la transicion a nombre de atributo pasa al estado ATTR
*   @param nombreAtributo nombre del atributo que se acaba de leer1
*   @return 0 si se ha ejecutado correctamente
*/
int transicionNombreAtributo(char* nombreAtributo) {
    nAttrs++;
    attrActual = strdup(nombreAtributo);
    printf("%s[ATTR_NAME]->%s%s El atributo actual (%d) es \"%s\" %s\n",BOLDGREEN,RESET,GREEN,nAttrs,nombreAtributo,RESET);
    BEGIN(ATTR);
    return 0;
}

/**
*   @brief Funcion para la transicion a valor de atributo pasa al estado ATTR_VAL
*   @param valorAtributo valor del atributo que se acaba de leer
*   @return 0 si se ha ejecutado correctamente
*/
int transicionValorAtributo(char* valorAtributo) {
    attrValActual = strdup(valorAtributo);
    printf("\n%s[ATTR_VAL]->%s%s El atributo actual (%d) es \"%s\" con valor: %s %s\n",BOLDGREEN,RESET,GREEN,nAttrs,attrActual,attrValActual,RESET);
    BEGIN(ATTR_VAL);
    return 0;
}

/**
*   @brief Funcion para cuadno se cierra una etiqueta y pasa al estado INICIO
*   @return 0 si se ha ejecutado correctamente
*/
int transicionCierreEtiqueta() {
    printf("%s\n[TAG>]->%s %s Cerrando la etiqueta \"%s\" con %d atributos %s\n",BOLDRED,RESET,RED,etiquetaActual,nAttrs,RESET);
    
    if (nAttrs > maxAtributos){
        maxAtributos = nAttrs;
        etiquetaMaxAttr = strdup(etiquetaActual);
    }
    
    BEGIN(INICIO);
    return 0;
}

int mostrarResultados(){
    printf("\n########### RESULTADOS ##############\n");
    printf("# Numero de comentarios: %d \n",nComentarios);
    printf("# Numero de instrucciones de procesado: %d \n",pins);
    printf("# Numero de etiquetas vacias: %d \n", lineasVacias);
    printf("# Etiqueta con mas atributos: %s, tiene: %d \n");

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
    mostrarResultados();
}
