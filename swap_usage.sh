#!/bin/bash

# Show swap useage by processes.

SUM=0
OVERALL=0

if [ "$UID" != "0" ]; then
   echo "This script must be run as root or with sudo." 1>&2
   exit 1
fi

for DIR in $(find /proc/ -maxdepth 1 -type d | egrep "^/proc/[0-9]") ; do
   PID=$(echo $DIR | cut -d / -f 3)
   PROG=$(ps -p $PID -o comm --no-headers)
   for SWAP in $(grep Swap $DIR/smaps 2>/dev/null | awk '{ print $2 }'); do
      (( SUM=$SUM+$SWAP ))
   done
 echo "PID=$PID - Swap used: ${SUM}K [$PROG]"
 (( TOTAL=$TOTAL+$SUM ))
 SUM=0
done

echo "Overall swap used: ${TOTAL}K"
