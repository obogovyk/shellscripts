#!/bin/bash

# Copyright (c)2014 Bogovyk Oleksandr <obogovyk@gmail.com>
# mysqlbd_backup.sh

DAYOFWEEK=$(date +%w)
LOGDATE=$(date +%d.%m.%Y)
LOGHOUR=$(date +%H:%M)
LOGFILE=/var/log/mysqldb_backup.log
LOGLIMIT_MB=$(du -m ${LOGFILE} | awk {'print $1'})
PARTITION=/dev/cciss/c0d0p2
DISK_SPACE=$(df -m | grep $PARTITION | awk {'print $4'})
DISK_LIMIT=5120
BACKUP_DIR=/home/db_backup
TAR_TMP=tmp.tar.gz
TAR_INCNAME=false
MAILADDR=(user1@example.com user2@example.com user3@example.com)

mail_backupdir_err() {
    echo "WARNING! Backup directory \"${BACKUP_DIR}\" not found, but new directory created. Backup files will be saved here." | mail -s "WARNING! \
    Backup directory not found, but new directory created." user1@example.com
}

mail_freespace_err() {
    echo "WARNING! Low disk space on \"$PARTITION\"! Please clean up drive minimum to $(($DISK_LIMIT/1024)) \
    Gb." | mail -s "WARNING! Low disk space to continue backup." user1@example.com user2@example.com
}

create_backup_dir() {
    mkdir /home/db_backup
}

prep_backup() {
    mkdir /home/tmp_backup
}

backup_zabbixdb() {
    mysqldump --single-transaction --default-character-set=utf8 -uroot -p****** zabbix > /home/tmp_backup/zabbix_sql.sql
}

backup_fulldb() {
    innobackupex --defaults-file=/etc/my.cnf --no-timestamp --user=root --password=****** /home/tmp_backup --no-lock
}

backup_commit() {
    innobackupex --apply-log /home/tmp_backup
}

tar_backup() {
    cd /home/tmp_backup
    tar -czf ${TAR_TMP} *
    if [ ${DAYOFWEEK} -eq "0" ]; then
	mv /home/tmp_backup/${TAR_TMP} /home/db_backup/${LOGDATE}-bak-full.tar.gz
    else
	mv /home/tmp_backup/${TAR_TMP} /home/db_backup/${LOGDATE}-bak-zabbix_inc.tar.gz
    fi
}

post_backup() {
if [ -d "/home/tmp_backup" ]; then
    cd /root
    rm -rf /home/tmp_backup
fi
}

# BEGIN BACKUP...
if [ ${UID} -ne "0" ]; then
    echo "WARNING! Only ROOT allow to run \"${0}\" script."
    exit 1
else
    echo "Welcome to MySQLd Backup! Continue..."
fi

# CHECK LOGFILE & LOGFILE SIZE
if [ -f ${LOGFILE} ]; then
	if [ ${LOGLIMIT_MB} -le "10" ]; then
echo "--- ${LOGDATE} ${LOGHOUR} ---" >> ${LOGFILE}
echo "SUCCESS! Logfile \"${LOGFILE}\" exist, log filesize is ${LOGLIMIT_MB} Mb. Continue process..." >> ${LOGFILE}
    else
    cat /dev/null > ${LOGFILE}
    echo "--- ${LOGDATE} ${LOGHOUR} ---" >> ${LOGFILE}
    echo "SUCCESS! Logfile \"${LOGFILE}\" exist, log filesize is ${LOGLIMIT_MB} Mb. Continue process..." >> ${LOGFILE}
	fi
else
    touch /var/log/mysqldb_backup.log
    LOGFILE=/var/log/mysqldb_backup.log
    echo "--- ${LOGDATE} ${LOGHOUR} ---" >> ${LOGFILE}
    echo "SUCCESS! Logfile \"${LOGFILE}\" exist, filesize ${LOGLIMIT_MB} Mb. Continue process..." >> ${LOGFILE}
fi

# CHECK BACKUP DIRECTORY
if [ -d ${BACKUP_DIR} ]; then
    echo "SUCCESS! Backup directory \"${BACKUP_DIR}\" exists. Continue process..." >> ${LOGFILE}
else
    echo "WARNING! Backup directory \"${BACKUP_DIR}\" not found, but new directory created." >> ${LOGFILE}
    create_backup_dir
    mail_backupdir_err
fi

# CHECK FREE SPACE
if [ ${DISK_SPACE} -lt ${DISK_LIMIT} ]; then
    echo "WARNING! Low disk space on \"${PARTITION}\"! Please clean up your drive to $((${DISK_LIMIT}/1024)) Gb." >> ${LOGFILE}
    mail_freespace_err
    exit 1
else
    echo "SUCCESS! Disk space is $((${DISK_SPACE}/1024)) Gb. Backup begin ${LOGDATE} at ${LOGHOUR}..." >> ${LOGFILE}
fi

# PREPARE AND CHOOSE BACKUP TYPE
if [ ${DAYOFWEEK} -eq "0" ]; then
    backup_fulldb
    backup_commit
else
    prep_backup
    TAR_INCNAME=true
    backup_zabbixdb
fi

# TAR BACKUP
tar_backup

# CLEAR TEMP DIRECTORY
post_backup

# CHECK TAR AND TAR INFORMATION
CHECK_TAR=$(ls /home/db_backup/ | grep -c ${LOGDATE})
if [ ${CHECK_TAR} -eq "1" ]; then
    if [ ${TAR_INCNAME} = "true" ]; then
	TAR_SIZE=$(du -m /home/db_backup/${LOGDATE}-bak-zabbix_inc.tar.gz | awk {'print $1'})
    else
	TAR_SIZE=$(du -m /home/db_backup/${LOGDATE}-bak-full.tar.gz | awk {'print $1'})
    fi
    echo "SUCCESS! Archive successfully created ${LOGDATE} at $(date +%H:%M). Archive size is: $TAR_SIZE Mb. Backup partition size is: $((${DISK_SPACE}/1024)) Gb." >> ${LOGFILE}
else
    echo "WARNING! Can't find created archive for date: ${LOGDATE}." >> ${LOGFILE}
fi

# EMAIL USERS
if [ ${DAYOFWEEK} -eq "0" ]; then
    for i in "${MAILADDR[@]}"
    do
    	echo -e "SUCCESS! Archive successfully created ${LOGDATE} at $(date +%H:%M).\nArchive size is $TAR_SIZE Mb. Backup partition \"${PARTITION}\" size is: $((${DISK_SPACE}/1024)) Gb." | mail -s "SUCCESS! Zabbix backup successfully created." ${i}
    done
else
    exit 0
fi

# ...END BACKUP 
