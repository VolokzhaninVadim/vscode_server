#!/bin/bash

echo $(date '+%Y-%m-%d %H %M %S') 'Create variables'
FILE=$(date '+%Y-%m-%d_%H_%M_%S')
ARCHIVE_TYPE='zst'
GPG_TYPE='gpg'
PROJECT='vscode_server'
DIRECTORY_SOURCE='/home/volokzhanin/server/repos/development/'$PROJECT
DIRECTORY_TARGET='/mnt/backup/backup/backup'
DIRECTORY_S3='/mnt/s3/backup/'$PROJECT
GPG_KEY=634064C6
GPG_PASSPHRASE=/home/volokzhanin/.gnupg/backup_passphrase

echo $(date '+%Y-%m-%d %H %M %S') 'Create archive'
tar --create \
    --zstd \
    --file=$DIRECTORY_TARGET/$FILE'_'$PROJECT'_''.'$ARCHIVE_TYPE \
    --ignore-failed-read \
    --preserve-permissions \
    --verbose \
$DIRECTORY_SOURCE

echo $(date '+%Y-%m-%d %H %M %S') 'Create encrypted archive'
gpg  --recipient $GPG_KEY \
    --symmetric \
    --batch \
    --passphrase-file $GPG_PASSPHRASE \
    --no-tty \
    --encrypt $DIRECTORY_TARGET/$FILE'_'$PROJECT'_''.'$ARCHIVE_TYPE

echo $(date '+%Y-%m-%d %H %M %S') 'Remove archive'
rm $DIRECTORY_TARGET/$FILE'_'$PROJECT'_''.'$ARCHIVE_TYPE

echo $(date '+%Y-%m-%d %H %M %S') 'Move file'
rsync --partial --progress $DIRECTORY_TARGET/$FILE'_'$PROJECT'_''.'$ARCHIVE_TYPE'.'$GPG_TYPE $DIRECTORY_S3
rm $DIRECTORY_TARGET/$FILE'_'$PROJECT'_''.'$ARCHIVE_TYPE'.'$GPG_TYPE

echo $(date '+%Y-%m-%d %H %M %S') 'Delete files older than n days'
find $DIRECTORY_S3 -mtime +14 \
    -type f \
    -delete
