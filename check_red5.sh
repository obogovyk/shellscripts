#!/bin/bash

usage() {
    echo "Usage: $0 <domain name>"
}

if [ $# -ne 1 ]
then
    usage
    exit 1
fi

HOST=$1
PORT=80
CURL=$(which curl|awk {'print $1'})
URL="http://${HOST}:${PORT}"
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
    
    if [ ${COUNT} -eq ${PROBES} ]; then
        echo "[ERROR]: Red5 failed to start after ${PROBES} probes."
        exit 1
    fi
done

echo "Red5 successfully started."
