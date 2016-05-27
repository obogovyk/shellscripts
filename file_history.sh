#!/bin/bash

# TEMPLATE
# TODO...
export LC_ALL=en_US.utf8

TAR=$(which tar)
RSYNC=$(which rsync)
BACKUP_DIR="/backup"
SYNC_DIRS=( "/opt/backup" "/bacula" )
CURR_DATE=$(date +%d.%m.%Y-%H:%M:%S)
YEST_DATE=$(date +%d.%m.%Y-%H:%M:%S -d "-1 day")

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." 1>&2
  exit 1
fi

if [ -z $RSYNC ] || [ -z $TAR ]; then
  echo "Please install necessary packages: TAR, RSYNC and try again."
  exit 1
fi

caheck_sync_dirs() {
    if [ ! -d $BACKUP_DIR ]; then
        echo "Backup directory: $BACKUP_DIR not foud!"
        exit 1
}

check_backup_dirs() {
  if [ ! -d "$BACKUP_DIR/$YEST_DATE-latest" ] && [ ! -d "$BACKUP_DIR/*-full"]; then
        return 1
    else
        return 0
  fi
}

make_full_backup() {
  mkdir $BACKUP_DIR/$CURR_DATE-full

  for i in ${SYNC_DIRS[@]}; do
    cp -f $i/* $BACKUP_DIR/$CURR_DATE-full/
  done
}

make_latest_backup() {
  mkdir $CURR_DATE

  for i in ${SYNC_DIRS[@]}; do
    cp -f $i $BACKUP_DIR/$YEST_DATE
  done
}

if [ check_backup_dirs -eq $0 ]; then
    
    elif 
    # check full backup
    # make latest
fi

  # if ...
  # rm -rf
  
  # if YEST_DATE dir exist
  #
    make_hardlinks
fi

# --- Create stat file: name,size(bytes),uid,gid,mod.time --- #

for i in ${SYNC_DIR[@]}; do
  $RSYNC -az $i $BACKUP_DIR/$CURR_DATE
  #stat --format=%Y $i; echo $i
done

# --- Create stat file: name,size(bytes),uid,gid,mod.time AFTER UPDATE --- #
