#!/bin/bash

# Author: Bogovyk Oleksanr <obogovyk@gmail.com>
# Description: Simple file backup (with history) using RSYNC Utility

export LC_ALL=en_US.utf8

TAR=$(which tar)
RSYNC=$(which rsync)
DIRS=( "/opt/etc" "/opt" )
BACKUP_DIR="/backup"
CURR_DATE=$(date +%d.%m.%Y-%H:%M:%S)
YEST_DATE=$(date +%d.%m.%Y-%H:%M:%S -d "-1 day")
BACKUP_DIR_EMPTY=True
BACKUP_EXPIRES_DAYS=0

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root (or with sudo privileges)." 1>&2
  exit 1
fi

[ -z "$(which $RSYNC)" ] || [ -z "$(which $RSYNC)" ] && \
{ echo "[INFO]: Please install necessary packages: TAR, RSYNC and try again."; exit 1; }

check_backup_dir_exists() {
  if [ ! -d $BACKUP_DIR ]; then
    echo "Backup directory: $BACKUP_DIR doesn't exists!"
  exit 1
  fi
}

is_backup_dir_empty() {
  if [ "$(ls -A $BACKUP_DIR)" ]; then
    $BACKUP_DIR_EMPTY=False
} 

make_full_backup() {
  if [ ! "$(ls -A $BACKUP_DIR/*-full)" ]; then
    mkdir $BACKUP_DIR/$CURR_DATE-full
    for i in ${HIST_DIRS[@]}; do
      cp -rf $i/* $BACKUP_DIR/$CURR_DATE-full/
    done
  fi  
}

make_latest_backup() {
  mkdir $CURR_DATE

  for i in ${HIST_DIRS[@]}; do
    cp -f $i $BACKUP_DIR/$YEST_DATE
  done
}


### MAKE COMPARE TWO ARRAYS (DIRS vs BACKUP_DIR)

  # if ...
  # rm -rf
  
  # if YEST_DATE dir exist
  #
    make_hardlinks
fi

# --- Create stat file: name,size(bytes),uid,gid,mod.time --- #

for i in ${HIST_DIR[@]}; do
  $RSYNC -az $i $BACKUP_DIR/$CURR_DATE
  #stat --format=%Y $i; echo $i
done

# --- Create stat file: name,size(bytes),uid,gid,mod.time AFTER UPDATE --- #
