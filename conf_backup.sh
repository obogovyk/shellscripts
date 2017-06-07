#!/bin/bash

export LC_ALL=en_US.utf8

TAR=$(which tar)
STORAGE="/mnt/storage"
BKP_DIR="${STORAGE}/conf.dev"
DATE=$(date +%d.%m.%Y-%H.%M)

[ -z ${TAR} ] && { echo "[INFO]: Required packages (tar) not found."; exit 1; }

FILES=(
    /etc/phpMyAdmin
    /etc/sssd
    /etc/zabbix
    /etc/my.cnf
    /etc/mongod.conf
    /etc/sysctl.conf
    /etc/php-fpm.conf
    /etc/php.ini
    /etc/nginx/conf.d
    /etc/security/limits.conf
    /home/{user}/.ssh
)

is_backdir_mounted(){
    if [ $(cat /proc/mounts| grep "${STORAGE}"| wc -l) -lt 1 ]; then
        echo "[ERROR]: Config backup aborted. ${STORAGE} directory not mounted!" > /var/log/conf.backup.err.log
    fi
}

is_backdir_mounted
if [ $? -eq 0 ]; then
    cd ${BKP_DIR} && ${TAR} -cvzf conf.dev-${DATE}.tar.gz -P ${FILES[@]}
fi

find ${BKP_DIR} -name "conf*" -type d -mtime +7 -delete
