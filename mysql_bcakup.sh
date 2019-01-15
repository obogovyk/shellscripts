#!/bin/bash

export LC_LANG=en_US.utf8

DATE=$(date +%d.%m.%Y-%H.%M)
STORAGE="/mnt/storagebox"
INNO="/usr/bin/innobackupex"
BKP_DIR="${STORAGE}/mysql.fullbak"
PASS=$(cat /opt/scripts/.dbpass|grep root|cut -d: -f2)
SERVICE="MySQL"

[ -z ${INNO} ] && { echo "[INFO]: Required packages (innobackupex) not found."; exit 1; }

inno_fullbackup(){
    ${INNO} --defaults-file=/etc/my.cnf --user=root --password=${PASS} ${BKP_DIR}/MySQL-fullbak-${DATE} --no-timestamp
}

inno_prepare(){
    ${INNO} --use-memory=2G --apply-log ${BKP_DIR}/MySQL-fullbak-${DATE}
}

is_backdir_mounted(){
    if [ $(cat /proc/mounts| grep -c "${STORAGE}") -lt 1 ]; then
        echo "[ERROR]: ${SERVICE} backup aborted. ${STORAGE} directory not mounted." >> /var/log/mysql.backup.err.log
    fi
}

is_backdir_mounted
if [ $? -eq 0 ]; then
    inno_fullbackup
    inno_prepare
fi

find ${BKP_DIR} -type d -mtime +6 -exec rm -rf '{}' '+'
