#!/bin/bash

export LC_LANG=en_US.utf8

DATEFMT=$(date +%d-%b-%Y)
PG_DUMP="/usr/pgsql-9.6/bin/pg_dump"
GZIP="$(which gzip)"
STORAGE="/mnt/storagebox"
BKP_DIR="${STORAGE}/confluence.db"
PASS=$(cat /opt/scripts/.dbpass|grep confluence|cut -d: -f2)
DB="confluencedb"

[ -z ${PG_DUMP} ] && { echo "[INFO]: Required package (pg_dump) not found on selected path."; exit 1; }

is_backdir_mounted(){
    if [ $(cat /proc/mounts| grep -c "${STORAGE}") -lt 1 ]; then
        echo "[ERROR]: ${DB} backup aborted. ${STORAGE} directory not mounted." >> /var/log/db.backup.err.log
    fi
}

postgres_backup(){
    PGPASSWORD="${PASS}" ${PG_DUMP} -U confluence_user -h 127.0.0.1 -p 5432 -C -Fp ${DB} | gzip > ${BKP_DIR}/${DB}_${DATEFMT}.sql.gz
}

is_backdir_mounted
if [ $? -eq 0 ]; then
    postgres_backup
fi

find ${BKP_DIR} -name "*.gz" -type f -mtime +6 -delete
