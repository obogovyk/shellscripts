#!/bin/bash

JSLINT=$(whereis jslint|awk {'print $2'})
JSDIR='/var/www/html/lookatmyhorse'

if [ ! -z "$JSLINT" ]; then
    for i in $(find $JSDIR -type f -name *.js); do
        $JSLINT $i
    done
else
    echo -e "[ERROR]: JSlint not found!\n[INSTALL]: npm install jslint -g"
    exit 1
fi
