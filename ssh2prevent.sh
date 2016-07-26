#!/bin/bash

# Script: ssh2prevent.sh
# Author: Bogovyk Oleksandr <obogovyk@gmail.com>

CHAIN="SSH_BLACKLIST"
RULE_NUM=1
INTERFACE="eth0"
SSH_PORT=22
FILTER="Invalid user"
COUNTER=5
IP_IGNORE_LIST=( "127.0.0.1" "131.34.22.11" )
IP_BLACK_LIST=( $(cat /var/log/secure | grep "$FILTER" | awk {'print $10'} | sort | uniq) )

if_chain_exists() {
    iptables -nL $CHAIN 2>&1 /dev/null
}

iptables_save(){
    service iptables save
    service iptables restart
}

if_chain_exists

if [ $? != 0 ]; then
    iptables -N $CHAIN
    iptables -A $CHAIN -j RETURN
fi

for i in ${IP_BLACK_LIST[@]}
do
    if [ $(cat /var/log/secure | grep $i | wc -l) -ge $COUNTER ]; then
        if [ $(iptables -nL $CHAIN | grep $i | wc -l) -eq 0 ]; then
            iptables -I $CHAIN $RULE_NUM -i $INTERFACE -s $i -p tcp -m tcp --dport $SSH_PORT -j REJECT --reject-with icmp-host-prohibited
        fi
    fi
done

iptables_save
