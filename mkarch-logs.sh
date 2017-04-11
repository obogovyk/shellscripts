#!/bin/bash

LOGS=($(ls|grep '[0-9]'|sort -n))
LATEST_N=$(ls | egrep -o '[0-9]*'|sort -n|tail -n 1)

if [ ${#LOGS[@]} -gt 1 ]; then
    for i in ${LOGS[@]}; do
        if [ $i != "runtime${LATEST_N}.log" ]; then
            tar cvzf "${i}.tar.gz" $i
            mv "${i}.tar.gz" "../../logs-app/"
            rm -f ${i}
        fi
    done
else
    echo "[INFO]: No logs to archive."
fi
