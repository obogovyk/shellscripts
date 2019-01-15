#!/bin/bash

export LC_LANG=en_US.utf8

DATE=$(date +%d.%m.%Y-%H.%M)
MONGODUMP=$(which mongodump)
STORAGE="/mnt/storagebox"
BKP_DIR="${STORAGE}/mongodb"
PASS=$(cat /opt/scripts/.dbpass|grep root|cut -d: -f2)
DIR_TEMPLATE="mongodump-${DATE}"
SERVICE="Mongodb"

[ -z ${MONGODUMP} ] && { echo "[INFO]: Required packages (mongodump) not found."; exit 1; }

mongo_prepare(){
    mkdir -p ${BKP_DIR}/${DIR_TEMPLATE}
}

mongo_backup(){
    ${MONGODUMP} -u root -p ${PASS} --authenticationDatabase "admin" -o ${BKP_DIR}/${DIR_TEMPLATE}
}

is_backdir_mounted(){
    if [ $(cat /proc/mounts| grep -c "${STORAGE}") -lt 1 ]; then
        echo "[ERROR]: ${SERVICE} backup aborted. ${STORAGE} directory not mounted." > /var/log/mongodb.backup.err.log
    fi
}

is_backdir_mounted
if [ $? -eq 0 ]; then
    mongo_prepare
    mongo_backup
fi

find ${BKP_DIR} -type d -mtime +6 -exec rm -rf '{}' '+'
