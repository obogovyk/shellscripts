#!/bin/bash

USER="$1"
DIRS=`ls`
for i in ${DIRS[*]}; do
    if [ -d $i ]; then
        grep "$USER:" $i/.git/config && echo $i
    fi
done
