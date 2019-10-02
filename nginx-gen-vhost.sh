#!/usr/bin/env bash
# domain list must be specified via $1 parameter variable

VHOST="vhost.conf.txt"

usage() {
    echo "Usage: $0 <NGINX femplate file>"
}

if [ $# -ne 1 ]
then
    usage
    exit 1
fi

while DOMAIN= read -r dom; do
    sed "s/{DOMAIN}/$dom/g" $VHOST > ${dom}.conf
done < "$1"
