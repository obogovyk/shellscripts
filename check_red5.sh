#!/bin/bash

# Script: check_red5.sh

HOST="${1:-example.com}"
PORT=80
URL="http://${HOST}:${PORT}"
CURL="/usr/bin/curl"
COUNT=0
PROBES=3

check_url() {
    STAT=$(${CURL} --silent -I ${URL}| head -1| awk {'print $2'})
}

check_url
while [ "${STAT}" != "200" ]; do
    echo "Red5 starting..."

    sleep 15
    check_url
    (( COUNT++ ))
    
    if [ ${COUNT} -ge ${PROBES} ]; then
        echo "[ERROR]: Red5Pro failed to start after ${PROBES} probes."
        exit 1
    fi
done

echo "Red5 successfully started."
