#!/bin/bash

if [ $# -ge 1 ]; then
    flexfile=$1
    outputfile="defaultLexCCompilation"

    res=$(flex $flexfile)

    if [ $# -ge 2 ]; then
        outputfile=$2
    fi


    gcc lex.yy.c -o $outputfile -lfl

    rm lex.yy.c
    ./$outputfile
else
    echo "Num de parametros incorrecto"
fi

exit