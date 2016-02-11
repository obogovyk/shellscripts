#!/bin/bash

DISC="sda"

echo "Schedulers: "
cat /sys/block/$DISC/queue/scheduler
echo ""

for S in noop deadline cfq; do 
    echo $S > /sys/block/$DISC/queue/scheduler;

    cat /sys/block/$DISC/queue/scheduler
    sync && /sbin/hdparm -tT /dev/$DISC && echo "----"
    sleep 10
