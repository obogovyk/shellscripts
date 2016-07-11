#!/bin/bash

# Description: CSS & JS npm minifier 

MINIFY=$(whereis minify|awk {'print $2'})
TYPES=( "*.css" ) # "*.js"
FILES=()

if [ ! -z "$MINIFY" ]; then
    for a in ${TYPES[@]}; do
        for i in $(find "`pwd`/frontend" -type f -name $a ); do
            if [[ $i != *".min."* ]]; then
                FILES+=($i)
            fi
        done
    done
else
    echo -e "[ERROR]: Minifier not found!\n[INSTALL]: sudo npm install minifier -g"
    exit 1
fi

for f in ${FILES[@]}; do
    $MINIFY $f
done
