#!/bin/bash

export LC_LANG=en_US.utf8

TAR=$(which tar)
STORAGE="/mnt/storagebox"
BKP_DIR="${STORAGE}/dev.config"
DATE=$(date +%d.%m.%Y-%H.%M)

[ -z ${TAR} ] && { echo "[INFO]: Required packages (tar) not found."; exit 1; }

FILES=(
    /etc/letsencrypt/archive
    /etc/.storagebox.txt
    /etc/phpMyAdmin
    /etc/sssd
    /etc/zabbix
    /etc/my.cnf
    /etc/mongod.conf
    /etc/sysctl.conf
    /etc/rsyslog.conf
    /etc/php-fpm.conf
    /etc/php.ini
    /etc/nginx/conf.d
    /etc/nginx/nginx-ldap-auth
    /etc/nginx/nginx.conf
    /etc/nginx/proxy_params
    /etc/nginx/proxy_buffering_params
    /etc/nginx/websocket_params
    /etc/nginx/.htpasswd
    /etc/security/limits.conf
    /etc/sysconfig/iptables
    /home/centos/.ssh
    /home/deploy/.ssh
    /home/deploy/.pm2/dump.pm2
    /opt/scripts
)

is_backdir_mounted(){
    if [ $(cat /proc/mounts| grep -c "${STORAGE}") -lt 1 ]; then
        echo "[ERROR]: Config backup aborted. ${STORAGE} directory not mounted!" > /var/log/conf.backup.err.log
    fi
}

is_backdir_mounted
if [ $? -eq 0 ]; then
    cd ${BKP_DIR} && ${TAR} -cvzf dev.config-${DATE}.tar.gz -P ${FILES[@]}
fi

find ${BKP_DIR} -name "dev.conf*" -type f -mtime +6 -delete
