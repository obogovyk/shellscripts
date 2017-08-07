#!/bin/bash

# Script: check_red5.sh
# Author: Bogovyk Oleksandr <obogovyk@gmail.com>

HOST="${1:-example.com}"
PORT=80
URL="http://${HOST}:${PORT}"
CURL="/usr/bin/curl"
COUNT=0
PROBES=4

while [ "${CHK}" != "200" ]; do
    echo "Red5 starting..."
    sleep 15
    (( COUNT++ ))
    CHK=$(${CURL} --silent -I ${URL}| head -1| awk {'print $2'})

    if [ ${COUNT} -ge ${PROBES} ]; then
        echo "[ERROR]: Red5Pro failed to start after ${PROBES} probes."
        exit 1
    fi
done

echo "Red5 successfully started."
