#!/bin/bash

Author: Bogovyk Oleksandr <obogovyk@gmail.com>
# ssh2prevent.sh

CHAIN="BLACKLIST"
RULE_NUM=1
INTERFACE="eth0"
DPORT=22
FILTER="Invalid user"
COUNTER=50
ACCESS_LIST=( $(cat /var/log/secure | grep "$FILTER" | awk {'print $10'} | sort | uniq) )

iptables_save(){
    service iptables save
    service iptables restart
}

for i in ${ACCESS_LIST[@]}
do
    if [ $(cat /var/log/secure | grep $i | wc -l) -ge $COUNTER ]; then
        if [ $(iptables -nvL $CHAIN | grep $i | wc -l) -eq 0 ]; then
        iptables -I $CHAIN $RULE_NUM -i $INTERFACE -s $i -p tcp -m tcp --dport $DPORT -j REJECT --reject-with icmp-host-prohibited
        fi
    fi
done

iptables_save
