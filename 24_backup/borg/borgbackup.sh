#!/bin/bash

LOCKFILE=/tmp/lockfile
if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "already running"
    exit
fi

trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
echo $$ > ${LOCKFILE}

BACKUP_HOST='192.168.100.10'
BACKUP_USER='root'
BACKUP_REPO='/var/backup'
LOG='/var/log/borg_backup.log'

export BORG_PASSPHRASE='123456'

borg create \
  --stats --list \
  ${BACKUP_USER}@${BACKUP_HOST}:${BACKUP_REPO}::"etc-borgcl-{now:%Y-%m-%d_%H:%M:%S}" \
  /etc 2>> ${LOG}

borg prune \
  -v --list \
  ${BACKUP_USER}@${BACKUP_HOST}:${BACKUP_REPO} \
  --keep-daily=30 \
  --keep-monthly=2 2>> ${LOG}

rm -f ${LOCKFILE}
