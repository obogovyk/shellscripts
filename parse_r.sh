#!/bin/bash

LOGFILE=$1
UNIQ_IPS=`cat $1| awk {'print $1'}| sort| uniq`

for i in ${UNIQ_IPS[@]}; do
    echo "$i - $(grep -c $i $LOGFILE)"
done
