#!/bin/bash

APP="http://redmine.cleveroad.com:5081"
CURL="/usr/bin/curl"
CHK=`${CURL} --silent -I ${APP}| head -1| awk {'print $2'}`
COUNT=0
PROBES=3

while [ "${CHK}" != "200" ]; do
    echo "Red5 continue starting..."
    sleep 15
    (( COUNT++ ))

    if [ ${COUNT} -ge ${PROBES} ]; then
        echo "[ERROR]: Red5Pro failed to start after ($PROBES) probes."
        exit 1
    fi
done
