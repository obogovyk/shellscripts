#!/bin/bash

# Description: runtime logs archive

LOGS=($(ls|grep '[0-9]'|sort -n))
LATEST=$(ls|grep '[0-9]'|sort -n|tail -n 1)

if [ ${#LOGS[@]} -gt 2 ]; then
    for i in ${LOGS[@]}; do
        if [ $i != $LATEST ] && [ $i != "runtime1.log" ]; then
            tar cvzf "$i.tar.gz" $i
            mv "$i.tar.gz" "../../logs-app/"
            rm -f $i
        fi
    done
else
    echo "[INFO]: No logs to archive."
fi
