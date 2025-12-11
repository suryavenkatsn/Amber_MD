#!/bin/bash

file=$(echo "$1" | awk -F '[.]' '{ print $1 }')
for file in *.agr; do
    if [ -f "$file" ]; then
        echo "Processing file: $file"
        xmgrace -nxy $file.agr -hdevice PNG -hardcopy -printfile $file.png
    fi
done


