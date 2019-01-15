#!/bin/bash

export LC_LANG=en_US.utf8

DATE=$(date +%d.%m.%Y-%H.%M)
PG_DUMP="$(which pg_dump)"
GZIP="$(which gzip)"
STORAGE="/mnt/storagebox"
BKP_DIR="${STORAGE}/postgresql.fullbak"
PASS=$(cat /opt/scripts/.dbpass|grep dev|cut -d: -f2)
SERVICE="PostgreSQL"

[ -z ${PG_DUMP} ] && { echo "[INFO]: Required packages (pg_dump) not found."; exit 1; }

DATABASES=(
    "test_dev"
    "test_stage"
)

postgres_backup(){
    for i in ${DATABASES[@]}; do
        PGPASSWORD="${PASS}" ${PG_DUMP} ${i} -U dev -h localhost| ${GZIP} > ${BKP_DIR}/${i}-${DATE}.psql.gz
    done
}

is_backdir_mounted(){
    if [ $(cat /proc/mounts| grep -c "${STORAGE}") -lt 1 ]; then
        echo "[ERROR]: ${SERVICE} backup aborted. ${STORAGE} directory not mounted." > /var/log/postgres.backup.err.log
    fi
}

is_backdir_mounted
if [ $? -eq 0 ]; then
    postgres_backup
fi

find ${BKP_DIR} -name "*.psql.gz" -type f -mtime +6 -delete
