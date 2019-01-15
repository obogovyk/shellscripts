#!/bin/bash

export LC_LANG=en_US.utf8

DATEFMT=$(date +%d-%b-%Y)
PG_DUMP="/usr/pgsql-9.6/bin/pg_dump"
GZIP="$(which gzip)"
STORAGE="/mnt/storagebox"
BKP_DBDIR="${STORAGE}/jira.db"
BKP_DTDIR="${STORAGE}/jira.conf"
DATA_DIR="/var/atlassian/application-data/jira"
PASS=$(cat /opt/scripts/.dbpass|grep jira|cut -d: -f2)
DB="jiradb"

[ -z ${PG_DUMP} ] && { echo "[INFO]: Required package (pg_dump) not found on selected path."; exit 1; }

is_backdir_mounted(){
    if [ $(cat /proc/mounts| grep -c "${STORAGE}") -lt 1 ]; then
        echo "[ERROR]: ${DB} backup aborted. ${STORAGE} directory not mounted." >> /var/log/db.backup.err.log
    fi
}

postgres_backup(){
    PGPASSWORD="${PASS}" ${PG_DUMP} -U jira_user -h 127.0.0.1 -p 5432 -C -Fp ${DB} | gzip > ${BKP_DBDIR}/${DB}_${DATEFMT}.sql.gz
}

data_backup() {
    cd ${DATA_DIR}
    tar -czf jira-data_${DATEFMT}.tar.gz data/ export/ plugins/ caches/ logos/ dbconfig.xml
}

sync_data() {
    cd ${DATA_DIR}
    cp -r *.tar.gz ${BKP_DTDIR}/
    rm -rf *.tar.gz
}

is_backdir_mounted
if [ $? -eq 0 ]; then
    postgres_backup
    data_backup
    sleep 1
    sync_data
fi

find ${BKP_DBDIR} -name "*.gz" -type f -mtime +6 -delete
