#!/bin/bash

BKP_DIR="/home/git/gogs-backups"
BUCKET_NAME="s3-example"
S3CMD=$(which s3cmd|awk {'print $1'})
OLD_ZIP=`find ${BKP_DIR} -name "*.zip" -type f -mtime 6|sed 's#.*/##'`

# Remove old zip from S3 bucket
if [ ${#OLD_ZIP[@]} -ne 0 ]; then
    for i in ${OLD_ZIP[@]}; do
        s3cmd rm s3://${BUCKET_NAME}/${i}
    done
fi

# Remove old zip from local folder
find ${BKP_DIR} -name "*.zip" -type f -mtime 6 -delete

# Backup Gogs
cd ${BKP_DIR} && ../gogs/gogs backup --config=/home/git/gogs/custom/conf/app.ini

# Sync latest one *.zip file with S3
cd ${BKP_DIR} && ${S3CMD} put `ls -t | head -n1` s3://${BUCKET_NAME}
