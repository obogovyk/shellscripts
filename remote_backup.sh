#!/usr/bin/env bash

export LC_LANG=en_US.utf8

usage() { echo "Usage: $0 [-l <local backup directory>] [-r <remote backup directory>] \
[-t <backup type - full|inc>] [-u <user>] [-s <server>] [-h <help>]" 1>&2; exit 1; }

while getopts ":l:r:u:s:t:h:" arg; do
    case "${arg}" in
    l)
        l=${OPTARG}
        ;;
    r)
        r=${OPTARG}
        ;;
    u)
        u=${OPTARG}
        ;;
    s)
        s=${OPTARG}
        ;;
    t)
        t=${OPTARG}
        [ $t == "full" ] || [ $t = "inc" ] || usage
        ;;
    h)
        usage
        ;;
    *)
        usage
        ;;
    esac
done

LOCAL_DIR="${l:-/home/user/backup}"
REMOTE_DIR="${r:-/home/user/dir2backup1}"
BACKUP_USER="${u:-ubuntu}"
REMOTE_SRV="${s:-1.2.3.4}"
BACKUP_TYPE="${t:-full}"

INS_DIRS=("Full" "FullOld" "Inc" "IncOld")

RSYNC=$(which rsync)

[ -z "${RSYNC}" ] && apt install rsync

full_backup() {
    ${RSYNC} -avzh ${BACKUP_USER}@${REMOTE_SRV}:${REMOTE_DIR}/ ${LOCAL_DIR}/Full
}

inc_backup() {
    ${RSYNC} -avzh ${BACKUP_USER}@${REMOTE_SRV}:${REMOTE_DIR}/ ${LOCAL_DIR}/Inc
}

sync_old() {
    rsync -avz ${LOCAL_DIR}/Full/ ${LOCAL_DIR}/FullOld/
    rsync -avz ${LOCAL_DIR}/Inc/ ${LOCAL_DIR}/IncOld/
}

if [ ! -d "${LOCAL_DIR}" ]; then
    mkdir "${LOCAL_DIR}" && cd "${LOCAL_DIR}"
    for i in ${INS_DIRS[*]}; do
        mkdir ${i}
    done
else
    cd "$LOCAL_DIR"
    for i in ${INS_DIRS[*]}; do
        [ ! -d ${i} ] && mkdir ${i}
    done
fi

if [ ${BACKUP_TYPE} == "full" ]; then
    full_backup
else
    [ "$(ls -A ${LOCAL_DIR}/Full)" ] && inc_backup || full_backup
    inc_backup
fi

sync_old
