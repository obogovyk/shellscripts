#!/bin/bash

# Script: parse_ip.sh
# Description: parse NGINX log file for uniq IPs more that ${LIMIT} conn. variable

LOGFILE=$1
UNIQ_IPS=`cat ${LOGFILE}| awk {'print $1'}| grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"| sort| uniq`
LIMIT=25

for i in ${UNIQ_IPS[@]}; do
    if [ "$(grep -c ${i} ${LOGFILE})" -ge "${LIMIT}" ]; then
        echo "${i} - $(grep -c ${i} ${LOGFILE}) - $(whois ${i}|grep '[N|n]et[N|n]ame'|awk {'print $2'})"
    fi
done
