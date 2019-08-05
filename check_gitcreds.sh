#!/bin/bash

PROJ_DIR='/home/example/projects'

usage() {
    echo "Usage: $0 <user name>"
}

if [ $# -ne 1 ]
then
    usage
    exit 1
fi

USER=$1
DIRS=`ls ${PROJ_DIR}`
for i in ${DIRS[@]}; do
    if [ -d $i ]; then
        grep "${USER}:" ${i}/.git/config && echo ${i}
    fi
done
