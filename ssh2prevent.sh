#!/bin/bash

# Script: ssh2prevent.sh for RHEL-based distros
# Author: Bogovyk Oleksandr <obogovyk@gmail.com>
# Add to crontab: 59 * * * * {{path_to_script}}/ssh2prevent.sh > /dev/null 2>&1

#!/bin/bash

export LANG=en_US.utf8

CHAIN="SSH2PREVENT"
INTERFACE="eth0"
SSH_PORT=22
D_FILTER="([0-9]{1,3}[\.]){3}[0-9]{1,3}"
W_FILTER="[I|i]nvalid\|[C|c]losed\|[D|d]isconnect\|[F|f]ailed"
COUNTER=5
RULE_NUM=1
IPTABLES=$(whereis iptables|awk {'print $2'})
SSH_LOG="/var/log/secure"
IP_IGNORE_LIST=( "127.0.0.1" "77.222.xx.xx" "77.222.xx.xx" "77.222.xx.xx" )
IP_BLACK_LIST=( $(cat $SSH_LOG | grep $W_FILTER | grep -E -o $D_FILTER | sort | uniq) )
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
    $IPTABLES -nL $CHAIN &> /dev/null
}

chain_clear() {
    $IPTABLES -F $CHAIN
}

iptables_save(){
    /sbin/service iptables save
}

chain_exists
if [ $? != 0 ]; then
    $IPTABLES -N $CHAIN
fi

chain_clear
for i in ${FILTERED_LIST[@]}; do
    if [ $(grep -c $i $SSH_LOG) -ge $COUNTER ]; then
        $IPTABLES -A $CHAIN -i $INTERFACE -s $i -p tcp -m tcp --dport $SSH_PORT -j REJECT --reject-with icmp-port-unreachable
    fi
done
$IPTABLES -A $CHAIN -j RETURN

if [ $($IPTABLES -nL INPUT | grep $CHAIN | wc -l) -eq 0 ]; then
    $IPTABLES -I INPUT $RULE_NUM -i $INTERFACE -p tcp -m multiport --dports $SSH_PORT -j $CHAIN
fi

iptables_save
