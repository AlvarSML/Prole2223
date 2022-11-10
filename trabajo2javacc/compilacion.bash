#!/bin/bash

# Compila todos los .java
compilar_java() {
    res=$(javac -d ./compiled *.java )
    if  [ $? -eq 1 ]; then
        echo "- [Javac] Error de compilacion de Java"
    else
        echo "-- Exito de compilacion --"
    fi
    rm ./*.java
}

compilar_archivo() {
    echo "- [Javacc] Compilando  $1 con debug $2 -"
    if [[ $2 -eq 1 ]]; then
        resultado=$(javacc -DEBUG_PARSER:true $1)
    else
        resultado=$(javacc -DEBUG_PARSER:false $1)
    fi
    if [ $? -eq 1 ]; then
        echo "- [Error] El javacc tiene errores"
        echo $resultado
        return 0
    else
        echo "- [Javacc] $1 Compliado a .Java con exito"
        compilar_java
    fi
}

if [ $# -ge 1 ]; then
    echo "- Leyendo argumentos de entrada -"
    declare -i debug
    debug=0
    
    for archivo in $@; do
        if [[ $archivo = -d ]];
        then
            debug=1
        else
            compilar_archivo $archivo $debug
        fi
    done
else
    for archivo in `*.jj`; do
        compilar_archivo $archivo
    done
fi

