#!/bin/bash

export LC_ALL=en_US.utf8

TODAY=$(date +%d.%m.%Y)
TAR=$(which tar)
MONGODUMP=$(which mongodump)
DUMP_DIR="/opt/mongodump"
MONGO_DB=""
LOG_FILE="/var/log/mongodump.log"
BAK_PARTITION="/dev/xvdf1"

[ -z ${MONGODUMP} ] || [ -z ${TAR} ] && \
{ echo "[INFO]: Necessary packages not found."; exit 1; }

check_dump_dir() {
  if [ $(cat /proc/mounts| grep $BAK_PARTITION| wc -l) -lt 1 ] || [ ! -d $DUMP_DIR ]; then
    echo "[ERROR]: Backup directory: $DUMP_DIR doesn't exist or partition not mounted." > $LOG_FILE
  fi
}

create_dump() {
    echo "Create dump..."
    $MONGODUMP --db $MONGO_DB --out $DUMP_DIR
}

create_arch() {
    $TAR -cvzf $MONGO_DB-$TODAY.tar.gz $MONGO_DB && rm -rf $MONGO_DB
}

log_success() {
    echo "MongoDB dump successfully created: $TODAY, \
archive size - $(du -sh $DUMP_DIR/$MONGO_DB-$TODAY.tar.gz| awk {'print $1'})." >> $LOG_FILE
}

if [ -f "$DUMP_DIR/$MONGO_DB-$TODAY.tar.gz" ]; then
    echo "MongoDB dump $MONGO_DB-$TODAY.tar.gz has been already created."
    exit 1
fi

check_dump_dir
if [ $? -eq 0 ]; then
    cd $DUMP_DIR \
    && create_dump \
    && create_arch
    log_success
    echo "[SUCCESS]: MongoDB dump successfully created. $LOG_FILE has been updated."
else
    echo "[ERROR]: MongoDB dump failed. $LOG_FILE has been updated."
    exit 1
fi
