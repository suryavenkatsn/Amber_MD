#!/bin/bash
for file in *.agr; do
    if [ -f "$file" ]; then
        echo "Processing file: $file"
        fname=$(echo "$file" | awk -F '[.]' '{ print $1 }')
        xmgrace -nxy $file -hdevice PNG -hardcopy -printfile $fname.png
    fi
done


