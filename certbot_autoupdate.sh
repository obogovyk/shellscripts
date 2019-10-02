#!/usr/bin/env bash

export LC_LANG=en_US.utf8

CERT_LIST=$(ls /etc/letsencrypt/live)
CERT_DISABLE=("")
SORTED=()
DBU=15

for x in ${CERT_LIST[@]}; do
    skip=
    for y in ${CERT_DISABLE[@]}; do
        [[ $x == $y ]] && { skip=1; break; }
    done
    [[ -n $skip ]] || SORTED+=("${x}")
done

for i in ${SORTED[@]}; do
    CERT=/etc/letsencrypt/live/${i}/cert.pem

    EXPD=`openssl x509 -enddate -noout -in ${CERT} | awk -F'=' '{print $2}'`
    CERTD="date +%D --date='${EXPD}'"
    ED=`eval ${CERTD}`
    TODAYD=$(date -d "+${DBU} days")

    if [ "`date -d "${ED}" +%s`" -le "`date -d "${TODAYD}" +%s`" ]; then
        echo "Certificate: ${i} will be updated."
        certbot certonly --dns-google --dns-google-credentials /etc/letsencrypt/.secrets/google.json --dns-google-propagation-seconds 90 --force-renewal -d ${i}
        service nginx reload
    fi
done
