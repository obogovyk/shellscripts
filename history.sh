#!/bin/bash

export LC_ALL=en_US.utf8

TAR=$(which tar)
RSYNC=$(which rsync)
STAT=$(which stat)
BACKUP_DIR="/backup"
SYNC_DIRS=( "/opt/backup" "/bacula" )
CURR_DATE=$(date +%d-%m-%Y)
YEST_DATE=$(date +%d-%m-%Y -d "-1 day")
REMOTE_HOST="10.0.0.0/24"

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." 1>&2
  exit 1
fi

if [ -z $RSYNC ] || [ -z $TAR ];
  echo "Please install necessary packages: TAR, RSYNC and try again."
  exit 1
fi

is_backup_dirs() {
  if [ ! -d "$BACKUP_DIR/$YEST_DATE" ] && [ ! -d "$BACKUP_DIR/Full-*"]; then
    return 0
  else
    return 1
  fi
}

make_latest() {
  mkdir $BACKUP_DIR/Full-$CURR_DATE

  for i in ${SYNC_DIRS[@]}; do
    cp -al $i $BACKUP_DIR/Latest-$CURR_DATE
  done
}

# make first increment ????????

make_hardlinks() {
  mkdir $CURR_DATE

  for i in ${SYNC_DIRS[@]}; do
    cp -al $i $BACKUP_DIR/$YEST_DATE
  done
}

if [ is_backup_dirs -eq $0 ]; then
    make_latest
else
  # Check existong currdate dir & remove if exist!!!
  # if ...
  # rm -rf
  
  # if YEST_DATE dir exist
  #
    make_hardlinks
fi

# --- Create stat file: name,size(bytes),uid,gid,mod.time --- #

for i in ${SYNC_DIR[@]}; do
  $RSYNC -avz $i $BACKUP_DIR/$CURR_DATE
  #stat --format=%Y $i; echo $i
done

# --- Create stat file: name,size(bytes),uid,gid,mod.time AFTER UPDATE --- #

echo $CURR_DATE && echo $YEST_DATE
