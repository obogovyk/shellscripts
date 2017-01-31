#!/bin/bash

# Script: check_red5.sh
# Author: Bogovyk Oleksandr <obogovyk@gmail.com>

APP="http://example.com:8080"
CURL="/usr/bin/curl"
COUNT=0
PROBES=5

while [ "${CHK}" != "200" ]; do
    (( COUNT++ ))
    echo "Check starting Server, (${COUNT}) probe..."
    sleep 30
    CHK=`${CURL} --silent -I ${APP}| head -1| awk {'print $2'}`

    if [ ${COUNT} -ge ${PROBES} ]; then
        echo "[ERROR]: Server failed to start after (${COUNT}) probes."
        exit 1
    fi
done

echo "Server successfully started."
