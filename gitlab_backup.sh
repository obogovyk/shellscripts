#!/bin/bash

export LC_ALL=en_US.utf8

PREFIX="config"
GITLAB="gitlab"
STORAGE="/mnt2/storagebox"
GITLAB_DUMPDIR="${STORAGE}/${GITLAB}.db"
GITLAB_CONFDIR="${STORAGE}/${GITLAB}.${PREFIX}"
GITLAB_WORKDIR="/var/opt/gitlab"
DATE=$(date +%d.%m.%Y-%H.%M)
TAR=$(which tar)
RSYNC=$(which rsync)

[ -z ${TAR} ] || [ -z ${RSYNC} ] && { echo "[INFO]: Required packages not found."; exit 1; }

is_backdir_mounted() {
    if [ $(cat /proc/mounts| grep "${STORAGE}"| wc -l) -lt 1 ]; then
        echo "[ERROR]: Gitlab config backup aborted. ${STORAGE} directory not mounted!" > /var/log/gitlab.backup.err.log
    fi
}

backup_confdir() {
    cd /etc && cp -r ${GITLAB} "${PREFIX}-${GITLAB}-${DATE}" \
    && ${TAR} -cvzf "${PREFIX}-${GITLAB}-${DATE}.tar.gz" "${PREFIX}-${GITLAB}-${DATE}" \
    && mv "${PREFIX}-${GITLAB}-${DATE}.tar.gz" "${GITLAB_CONFDIR}" \
    && rm -rf "${PREFIX}-${GITLAB}-${DATE}"
}

is_backdir_mounted
if [ $? -eq 0 ]; then
    backup_confdir
fi

find ${GITLAB_CONFDIR} -name "conf*" -type f -mtime +6 -delete

${RSYNC} -avz --modify-window=1 ${GITLAB_WORKDIR}/backups/ ${GITLAB_DUMPDIR} --delete
