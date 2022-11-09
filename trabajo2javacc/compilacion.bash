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
    echo "- [Javacc] Compilando  $1 -"
    resultado=$(javacc $1)
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
    for archivo in $@; do
        compilar_archivo $archivo
    done
else
    for archivo in `*.jj`; do
        compilar_archivo $archivo
    done
fi

