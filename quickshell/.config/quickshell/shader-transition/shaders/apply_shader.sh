#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

NAME="$1"

if [ ! -f "./$NAME" ]; then
    echo "Error: no file named '$NAME' found in the current folder."
    exit 1
fi

if /usr/lib/qt6/bin/qsb --qt6 -b -o ../shader.frag.qsb "$NAME"; then
    echo "Success: '$NAME' was compiled successfully."
else
    echo "Error: compilation failed." >&2
    exit 1
fi
