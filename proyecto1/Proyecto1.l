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

%{
#include <math.h>
%}

%x INICIO PINS COMM CDATA INI_TAG NAMESPACE ATTR ATTR_VAL

letra   [a-zA-Z]
digito  [0-9]
digitos ({digito})+
tabulador   \t
blanco [\t\n\r ]
espacio [\t\r ]
mayus [A-Z]
palabra ({letra}|{digito})+

cdata_ini (<!\[CDATA)
cdata_close  (\]\]>)

pi_ini (<?)
pi_close (?>)

comm_ini (<!--)
comm_close (-->)

tag_ini (<)
tag_close (/>|>)
tag_name ({blanco}*{palabra})
namespace ({tag_name:})


%%

<INICIO>{cdata_ini}     {BEGIN(CDATA);/*Cosas de cdata*/}
<CDATA>{cdata_close}    {BEGIN(INICIO);/*Fin del cdata*/}

<INICIO>{pi_ini}        {BEGIN(PINS);}
<PINS>{pi_close}        {BEGIN(INICIO);}

<INICIO>{comm_ini}      {BEGIN(COMM);}
<COMM>{comm_close}      {BEGIN(INICIO)}

<INICIO>{tag_ini}       {BEGIN(INI_TAG);}
<INI_TAG>{tag_name}     {BEGIN(ATTR)}
<INI_TAG>{namespace}    {BEGIN(NAMESPACE);/*!Puede estar mal la definicion*/}
<INI_TAG>{tag_close}    {BEGIN(INICIO);}



.|\n {ECHO;}

%%
int main( int argc, char **argv ){
    ++argv, --argc;	/* skip over program name */
	if ( argc > 0 )
	    yyin = fopen( argv[0], "r" );
	else
	    yyin = stdin;

	yylex();
}
