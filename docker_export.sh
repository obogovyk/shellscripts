#!/bin/bash

export LC_ALL=en_US.utf8

DOCKER=$(which docker)
STORAGE="/mnt/storagebox"
BKP_DIR="${STORAGE}/docker"
DATE_FMT=$(date +%d%m%Y)
CONTAINER_ID="0a77b61f5229"
VALUE=$(cat docker_id)
PROJECT=""

[ -z ${DOCKER} ] && { echo "[ERR]: Required packages (docker) not found."; exit 1; }

increment_id() {
    echo "$(( ${VALUE}+1 ))" > docker_id
}

docker_export() {
    ${DOCKER} export ${CONTAINER_ID} > ${BKP_DIR}/${PROJECT}_${DATE_FMT}_${VALUE}.tar
}

is_backdir_mounted(){
    if [ $(cat /proc/mounts| grep "${STORAGE}"| wc -l) -lt 1 ]; then
        echo "[ERR]: Docker backup aborted. ${STORAGE} directory not mounted!" > /var/log/docker.export.err.log
    fi
}

is_backdir_mounted
if [ $? -eq 0 ]; then
    docker_export
    increment_id
fi
