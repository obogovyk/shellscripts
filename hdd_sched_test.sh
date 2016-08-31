#!/bin/bash

# Script: hdd_sched_test.sh

DISC="sda"

echo "Default scheduler: "
cat /sys/block/$DISC/queue/scheduler
echo ""

for S in $(sed "s/\[//;s/\]//" /sys/block/sda/queue/scheduler); do 
    echo $S > /sys/block/$DISC/queue/scheduler;

    cat /sys/block/$DISC/queue/scheduler
    sync && /sbin/hdparm -tT /dev/$DISC && echo "----"
    sleep 5
