
%{
    /*
    *   Usando flex crear un programa para procesar un documento XML 
    *   realizando las operaciones necesarias para que al finalizar el 
    *   procesado permita mostrar las siguientes estadísticas:
    *       + el número de comentarios.
    *       + el número de elementos vacíos (finalizan sin tener etiquetas 
    *         anidadas ni texto en su interior).
    *       + el nombre de la etiqueta que contiene más atributos y su número.
    *       - el espacio de nombres con valor más largo y su prefijo asociado, 
    *         si es que lo tiene.
    *
    *   El contenido de las secciones CDATA se deben ignorar para todas 
    *   las estadísticas.
    */
    


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

// Flag para etiqueta vacia
short int vacio = 1;

// Nombre de la etiqueta con mas atributos
char* etiquetaMaxAttr;
char* etiquetaActual;
// Numero maximo de atributos en una etiqueta
int maxAtributos = 0;

// Atributo actual y su valor (sin uso actual)
char* attrActual;
char* attrValActual;

// Etiqueta actual al completo (sin uso)
char* etiquetaActualcompleta;

// No se si usarla
char** arrAtributos;

// Atributos de la etiqueta actual
int nAttrs = 0;

// Gestion del namespace
char* maxPrefix;
char* maxNamespace;
char* prefijoActual;
int lenMaxNamespace = 0;

// Auxiliares (Sin uso)
int pins = 0;
int lineasVacias = 0;

/* Declaraciones de funciones (Mover a .h) */
int entradaComentario();
int entradaPInstruction();
int guardarEtiqueta(char* nombre);
int mostrarResultados();
int transicionNombreAtributo(char* nombreAtributo);
int transicionValorAtributo(char* valorAtributo);
int transicionCierreEtiqueta();
int transicionFinEtiqueta();
int transicionAutoFinEtiqueta();
int transicionPrefijo(char* namespace);

int transicionNamespace();
int transicionNamespaceVal(char* namespaceurl);


%}

%x INICIO PINS COMM CDATA INI_TAG TAG_NAME TAG_END TAG_NAME_CLOSE PREFIJO NAMESPACE ATTR ATTR_VAL DOCTYPE NAMESPACEVAL

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

doctype     (<!DOCTYPE{blanco}*)

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

tag_name    ({palabra}) 
prefijo     ({tag_name}:)

attr_name       ([a-zA-Z\-\_][a-zA-Z0-9]*)
attr_val        ({blanco}*["']{texto}["'])
attr_namespace  ({palabra}:{palabra})
namespace       ({blanco}*(xmlns:){palabra})

%%
<INICIO>{cdata_ini}     {BEGIN(CDATA);/*Cosas de cdata*/}
<CDATA>{cdata_close}    {BEGIN(INICIO);/*Fin del cdata*/}

<INICIO>{pi_ini}        {entradaPInstruction();BEGIN(PINS);}
<PINS>{pi_close}        {BEGIN(INICIO);}

 /* Procesamiento de la instruccion DOCTYPE */
<INICIO>{doctype}       {BEGIN(DOCTYPE);}
<DOCTYPE>{cierre_derecha}   {BEGIN(INICIO);}

 /* Procesamiento de comentarios */
<INICIO>{comm_ini}      {entradaComentario();}
<COMM>{comm_close}      {BEGIN(INICIO);}

 /* Procesamiento de etiquetas */
<INICIO>{
    {apertura_izq}      {BEGIN(INI_TAG);}
}

 /* Una vez capturada la apertura de una etiqueta se identifica el tipo */
<INI_TAG>{
    {tag_name}     {guardarEtiqueta(yytext);BEGIN(TAG_NAME);}
    {prefijo}      {transicionPrefijo(yytext);}
    {tag_close}    {transicionCierreEtiqueta();/* La etiqueta se cierra sin atributos */}
    (\/{blanco}*)  {BEGIN(TAG_END);}
}

<TAG_END>{
    {tag_name}  {transicionFinEtiqueta(yytext);}
}

 /* Despues de un prefijo siempre hay una etiqueta -> TAG_NAME */
<PREFIJO>{tag_name}     {guardarEtiqueta(yytext);}

<TAG_NAME>{
    {attr_name}                 {transicionNombreAtributo(yytext);/*Hay al menos un atributo*/}
    {blanco}*{cierre_derecha}   {transicionCierreEtiqueta(); /*Se cierra sin atributos*/}
    {auto_cierre}               {transicionAutoFinEtiqueta();}
    /* Si se detecta un namespace xmlns:prefijo se pasa a leer el valor del prefijo -> NAMESPACE*/
    {namespace}                 {transicionNamespace();}
}

 /**
  * Se lee el valor del prefijp, como si fuese un atributo normal y se pasa a los atributos regulares
  * -> TAG_NAME
  */
<NAMESPACE>{
    (=)          {;}
    {attr_val}   {transicionNamespaceVal(yytext);}
}



<ATTR>{
    {blanco}+         {;}
    (=)               {;}
    {attr_val}        {transicionValorAtributo(yytext); /* Despues de una atributo siempre hay un valor */ }
}

<ATTR_VAL>
{
    {blanco}+          {;}
    {cierre_derecha}   {transicionCierreEtiqueta(); /* Cuando despues de un atributo se cierra la etiqueta */}
    {auto_cierre}      {transicionAutoFinEtiqueta();}
    {attr_name}        {transicionNombreAtributo(yytext); /* cuando despues de un atributo hay otro*/}

}



.|\n {;}

%%

int entradaComentario() {
    nComentarios++;
    printf("[COMM]-> Procesando %d comentario \n",nComentarios);
    BEGIN(COMM);
    return 0;
}

int entradaPInstruction() {
    pins++;
    printf("[PINS]-> Entrado en una instruccion de Procesado \n");
    return 0;
}

int guardarEtiqueta(char* nombre){
    // Reset del numero actual de atributops
    nAttrs = 0;
    // Se asume que empieza vacia
    vacio = 1;
    // La ultima etiqueta abierta pasa a ser la actual 
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
    printf("%s\n[ATTR_NAME]->%s%s El atributo actual (%d) es \"%s\" %s\n",BOLDGREEN,RESET,GREEN,nAttrs,nombreAtributo,RESET);
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

/**
*   @brief Funcion para cuadno se termina o finaliza una etiqueta en la misma linea y pasa al estado INICIO
*   @return 0 si se ha ejecutado correctamente
*/
int transicionAutoFinEtiqueta() {
    printf("%s\n[TAG/>]->%s %s Cerrando la etiqueta \"%s\" con %d atributos %s\n",BOLDRED,RESET,RED,etiquetaActual,nAttrs,RESET);
    nVacios++;    
    BEGIN(INICIO);
    return 0;
}

/**
*   @brief Funcion para cuadno se termina o finaliza una etiqueta en bloque y pasa al estado INICIO
*           se usa una flag "vacio" para comprobar que no hay nada dentro de la ultima etiqueta anidada
*   @return 0 si se ha ejecutado correctamente
*/
int transicionFinEtiqueta(char* etiqueta) {
    printf("%s\n[</TAG>]->%s %s Finalizando la etiqueta \"%s\" con %d atributos %s\n",BOLDRED,RESET,RED,etiqueta,nAttrs,RESET);
    printf("-- '%s' -- '%s' -- %d -- %d \n",etiqueta,etiquetaActual,vacio,nVacios);
    if ((strcmp(etiqueta,etiquetaActual) == 0) && (vacio == 1)){
        nVacios++;
    } else {
        // Reset de la flag de etiqueta vacia
        vacio = 1;
    }

    // como se ha finalizado el bloque la etiqueta actual pasa a ser nula
    // etiquetaActual = NULL;
    BEGIN(TAG_NAME);
}

/**
*   @brief Captura el prefijo actual
*   @param prefix prefijo de la etiqueta actual
*   @return 0 si se ha ejecutado correctamente
*/
int transicionPrefijo(char* prefix){
    prefijoActual = strdup(prefix);
    BEGIN(INI_TAG);
    return 0;
}

/**
*   @brief Indica que el atributo actual es de tipo namespace XSLNS + prefijo
*           realmente no calcula nada mas
*   @return 0 si se ha ejecutado correctamente
*/
int transicionNamespace(){
    BEGIN(NAMESPACE);
    return 0;
}

/**
*   @brief Captura el valor del namespace, comprueba si es el mas largo
*   @param namespaceurl valor del atributo namespace
*   @return 0 si se ha ejecutado correctamente
*/
int transicionNamespaceVal(char* namespaceurl){
    if(strlen(namespaceurl) > lenMaxNamespace ){
        lenMaxNamespace = strlen(namespaceurl);
        maxNamespace = strdup(namespaceurl);
        maxPrefix = strdup(prefijoActual);
    }
    BEGIN(TAG_NAME);
    return 0;
}

int mostrarResultados(){
    printf("\n########### RESULTADOS ##############\n");
    printf("# Numero de comentarios: %d \n",nComentarios);
    // printf("# Numero de instrucciones de procesado: %d \n",pins);
    printf("# Numero de etiquetas vacias: %d \n", nVacios);
    printf("# Etiqueta con mas atributos: %s, tiene: %d \n", etiquetaMaxAttr, maxAtributos);
    printf("# El prefijo '%s' tiene el namespace mas largo: %s\n",maxPrefix,maxNamespace);

}

int main( int argc, char **argv ){
    ++argv, --argc;	/* skip over program name */
    int prueba = 0;

	if ( argc > 0 )
	    yyin = fopen( argv[0], "r" );
	else
	    yyin = stdin;

    BEGIN(INICIO);
	yylex();
    mostrarResultados();
}
