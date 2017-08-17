#!/bin/bash

export LC_ALL=en_US.utf8

TAR=$(which tar)
STORAGE="/path/to/dir"
BKP_DIR="${STORAGE}/conf.dev"
DATE=$(date +%d.%m.%Y-%H.%M)

[ -z ${TAR} ] && { echo "[INFO]: Required packages (tar) not found."; exit 1; }

FILES=(
    /etc/letsencrypt/archive
    /etc/phpMyAdmin
    /etc/sssd
    /etc/zabbix
    /etc/my.cnf
    /etc/mongod.conf
    /etc/sysctl.conf
    /etc/php-fpm.conf
    /etc/php.ini
    /etc/nginx/.htpasswd
    /etc/nginx/conf.d
    /etc/nginx/nginx.conf
    /etc/security/limits.conf
    /etc/sysconfig/iptables
    /home/centos/.ssh
    /home/deploy/.ssh
    /opt/scripts
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

find ${BKP_DIR} -name "conf*" -type f -mtime +6 -delete
