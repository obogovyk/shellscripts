#!/bin/bash

SERVER=$1
PORT=${2:-443}
TIMEOUT=5
end_date="$(/usr/bin/timeout $TIMEOUT /usr/bin/openssl s_client -host $SERVER -port $PORT -showcerts < /dev/null 2>/dev/null | sed -n '/BEGIN CERTIFICATE/,/END CERT/p' | openssl x509 -enddate -noout 2>/dev/null | sed -e 's/^.*\=//')"

if [ -n "$end_date" ]; then
    end_date_seconds=$(date "+%s" --date "$end_date")
    now_seconds=$(date "+%s")
    LEFT=$(( ($end_date_seconds-$now_seconds)/24/3600 ))
    echo $LEFT
else
    exit 124
fi
