#!/bin/bash

export PATH=${PATH}:/usr/local/sbin:/sbin:/usr/sbin:/bin:/usr/bin

TIMEOUT=30
OARETVAL=-0.5

if echo "${BASH_SOURCE}" | grep -q "zabbix" ; then
  ZABBIX_TIMEOUT=`grep -i '^Timeout' /etc/zabbix/zabbix_server.conf 2>/dev/null | awk -F= '{print $2}' | tr -cd '0-9'`
  if [ -z "${ZABBIX_TIMEOUT}" ] ; then
    TIMEOUT=3
else
    TIMEOUT=$(( ${ZABBIX_TIMEOUT} - 1 ))
  fi
fi

HOST=$(echo "$*" | awk {'print $1'})
PORT=$(echo "$*" | awk {'print $2'})
SCRATCH=`mktemp`

if [ -z "${HOST}" ]; then
  echo "[ERROR]: Missing parameter values (host,port - default 443)."
  exit 1
fi
[ -z "${PORT}" ] && PORT=443

TLS=
echo "x${PORT}x" | egrep -q 'x(25|587)x'  && TLS="-crlf -starttls smtp"
echo "x${PORT}x" | egrep -q 'x110x'       && TLS="-starttls pop3"
echo "x${PORT}x" | egrep -q 'x21x'        && TLS="-starttls ftp"
echo "x${PORT}x" | egrep -q 'x143x'       && TLS="-starttls imap"

echo "" | openssl s_client -connect ${HOST}:${PORT} ${TLS}  2>/dev/null >${SCRATCH} &
sleep .1

let TIMEOUT*=2

n=1
while [ ! -s ${SCRATCH} ] ; do
  sleep .48
  [ $n -ge ${TIMEOUT} ] && break
  let n++
done

if [ -s ${SCRATCH} ] ; then
  EXPIRE_DATE=`sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' ${SCRATCH} | openssl x509 -enddate -noout 2>/dev/null | sed 's/notAfter\=//'`
  if [ ! -z "${EXPIRE_DATE}" ]; then
    EXPIRE_SECS=`date -d "${EXPIRE_DATE}" +%s`
    EXPIRE_TIME=$(( ${EXPIRE_SECS} - `date +%s` ))

    RETVAL=$(( ${EXPIRE_TIME} / 24 / 3600 ))
  fi
else
  kill -9 %1 2>/dev/null
fi

rm -f ${SCRATCH} 2>/dev/null
echo ${RETVAL}
