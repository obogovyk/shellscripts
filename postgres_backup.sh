#!/bin/bash

export LC_ALL=en_US.utf8

PG_DUMP="$(which pg_dump)"
GZIP="$(which gzip)"
DATE=$(date +%d.%m.%Y-%H.%M)
STORAGE="/path/to/storage"
BKP_DIR="${STORAGE}/postgresql"
PASS=$(cat .sqlpass|grep root|cut -d: -f2)

[ -z ${PG_DUMP} ] && { echo "[INFO]: Required packages (pg_dump) not found."; exit 1; }

DATABASES=(
    "*_dev"
    "*_stage"
)

postgres_backup(){
    for i in ${DATABASES[@]}; do
        PGPASSWORD="${PASS}" ${PG_DUMP} ${i} -U dev -h localhost| ${GZIP} > ${BKP_DIR}/${i}-${DATE}.psql.gz
    done
}

is_backdir_mounted(){
    if [ $(cat /proc/mounts| grep "${STORAGE}"| wc -l) -lt 1 ]; then
        echo "[ERROR]: MySQL backup aborted. ${STORAGE} directory not mounted!" > /var/log/postgres.backup.err.log
    fi
}

is_backdir_mounted
if [ $? -eq 0 ]; then
    postgres_backup
fi

find ${BKP_DIR} -name "*.psql.gz" -type f -mtime +6 -delete
