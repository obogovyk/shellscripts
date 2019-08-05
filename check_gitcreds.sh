#!/bin/bash

usage() {
    echo "Usage: $0 <user name>"
}

if [ $# -ne 1 ]
then
    usage
    exit 1
fi

USER=$1
DIRS=`ls`
for i in ${DIRS[*]}; do
    if [ -d $i ]; then
        grep "${USER}:" ${i}/.git/config && echo ${i}
    fi
done
