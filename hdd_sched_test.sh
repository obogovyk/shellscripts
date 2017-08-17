#!/bin/bash

# Author: Oleksandr Bogovyk
# Script: HDD Scheduler test

DISC=$1

echo "Default scheduler: "
cat /sys/block/$DISC/queue/scheduler
echo ""

for S in $(sed "s/\[//;s/\]//" /sys/block/sda/queue/scheduler); do 
    echo $S > /sys/block/${DISC}/queue/scheduler;

    cat /sys/block/$DISC/queue/scheduler
    sync && /sbin/hdparm -tT /dev/$DISC && echo "----"
    sleep 5
