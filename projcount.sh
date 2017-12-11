#!/bin/bash

DIRS=0
PRJ="/home/deploy/projects"
STATES=($(ls ${PRJ}))

for x in ${STATES[@]}; do
    for y in $(ls ${PRJ}/${x}); do
        if [ -d ${PRJ}/${x}/${y} ]; then
            DIRS=$((DIRS+1))
        fi
    done
    echo "Total active ${x} projects: ${DIRS}"
    DIRS=0
done
