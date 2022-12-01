#!/bin/bash
# se asume que primero se mete el .l y luego el .y
# el .l y el .y se llaman igual

if [ $# -gt 0 ]; then
    # si solo se pasa el nomnre del .l
    arch=$1
else
    arch="*.l"
fi

res=$(flex $arch)

if [ $? -eq 1 ]; then
    echo "- [Flex] Error de compilacion"
    echo $res
    return 1
fi
echo "- [Flex] Compilacion con exito"

if [ $# -gt 1 ]; then
    # si se ha pasasdo un .l y .y
    arch=$2
else
    arch="*.y"
fi

res=$(bison -yd $arch)

if [ $? -eq 1 ]; then
    echo "- [Bison] Error de compilacion"
    echo $res
    exit 1
fi
echo "- [Bison] Compilacion con exito"

if [ $# -gt 2 ]; then
    # si se ha pasasdo un archivo para el output
    arch=$3
    res=$(gcc lex.yy.c y.tab.c -o $arch -lfl)
else
    res=$(gcc lex.yy.c y.tab.c -lfl)
fi

if [ $? -eq 1 ]; then
    echo "- [C] Error de compilacion"
    echo $res
else
    echo "- [*] Compilado con exito"
fi

exit $?
