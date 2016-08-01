#!/bin/bash

# Script: ssh2prevent.sh for RHEL-based distros
# Author: Bogovyk Oleksandr <obogovyk@gmail.com>

export LC_ALL=en_US.utf8

CHAIN="SSH2PREVENT"
RULE_NUM=1
INTERFACE="eth0"
SSH_PORT=22
FILTER="([0-9]{1,3}[\.]){3}[0-9]{1,3}"
COUNTER=5
SSH_LOG="/var/log/secure"
IP_IGNORE_LIST=( "127.0.0.1" "133.33.22.11" )
IP_BLACK_LIST=( $(cat $SSH_LOG | grep -E -o "$FILTER" | sort | uniq) )
FILTERED_LIST=()

for x in ${IP_BLACK_LIST[@]}; do
    skip=
    for y in ${IP_IGNORE_LIST[@]}; do
        if [ $x == $y ]; then
            skip=1
            break
        fi
    done
    [[ -n $skip ]] || FILTERED_LIST+=("$x")
done

chain_exists() {
    iptables -nL $CHAIN &> /dev/null
}

#chain_clear() {
#    iptables -F $CHAIN
#}

iptables_save(){
    service iptables save
    service iptables restart
}

chain_exists
if [ $? != 0 ]; then
    iptables -N $CHAIN
    iptables -A $CHAIN -j RETURN
fi

#chain_clear
for i in ${FILTERED_LIST[@]}; do
    if [ $(grep -c $i $SSH_LOG) -ge $COUNTER ]; then
        if [ $(iptables -nL $CHAIN | grep $i | wc -l) -eq 0 ]; then
            iptables -I $CHAIN $RULE_NUM -i $INTERFACE -s $i -p tcp -m tcp --dport $SSH_PORT -j REJECT --reject-with tcp-reset
        fi
    fi
done

iptables_save
