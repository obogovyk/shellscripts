#!/bin/bash

export LC_ALL=en_US.utf8

DATE=$(date +%d.%m.%Y-%H.%M)
STORAGE="/mnt/storagebox"
INNO="/usr/bin/innobackupex"
BKP_DIR="/mnt/storagebox/mysql.dev"
PASS=*********

[ -z ${INNO} ] && { echo "[INFO]: Required packages (innobackupex) not found."; exit 1; }

inno_fullbackup(){
    ${INNO} --defaults-file=/etc/my.cnf --user=root --password=${PASS} ${BKP_DIR}/MySQL-fullbak-${DATE} --no-timestamp
}

inno_prepare(){
    ${INNO} --use-memory=1G --apply-log ${BKP_DIR}/MySQL-fullbak-${DATE}
}

is_backdir_mounted(){
    if [ $(cat /proc/mounts| grep "${STORAGE}"| wc -l) -lt 1 ]; then
        echo "[ERROR]: MySQL backup aborted. ${STORAGE} directory not mounted!" > /var/log/mysql.backup.err.log
    fi
}

is_backdir_mounted
if [ $? -eq 0 ]; then
    inno_fullbackup
    inno_prepare
fi

find /mnt/storagebox/mysql.dev -type d -mtime +6 -exec rm -rf '{}' '+'
