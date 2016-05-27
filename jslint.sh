#!/bin/bash

JSLINT=$(whereis jslint|awk {'print $2'})
if [ ! -z "$JSLINT" ]; then
    for i in $(find `pwd` -type f -name *.js); do
        $JSLINT $i
    done
else
    echo -e "[ERROR]: JSlint not found!\n[INSTALL]: npm install jslint -g"
    exit 1
fi
