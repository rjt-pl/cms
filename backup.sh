#!/bin/sh
#
# backup.sh CMS Racing Backup
#
# 2022 Ryan Thompson <i@ry.ca>

#
# Settings
#
SSH_TARGET='cms'
TIMESTAMP=`date +%Y-%m-%dT%H%M`
FILE="cmsracing_$TIMESTAMP.tar.gz"
BANDWIDTH=1024 # kbps. Max scp bandwidth

# Destination
DEST='cmsracin@ry.ca:backups'
TMP='/data/tmp'

# MySQL Username/pw in ~/.my.cnf on destination


## Pretty print a status message
status() {
    echo "\e[0;36m-=> \e[1;36m $*\e[0m"
}

status "Generating MySQL Dump"
ssh $SSH_TARGET mysqldump --add-drop-table $MYSQL_DB > $MYSQL_DB.sql

# Normally I'd use this:
# ssh $SSH_TARGET tar cvzf $FILE -X backup_exclude.txt .
# But we don't have the server CPU or disk space for that.
# Go file by file... this will take longer, but will work.
# I enable compression here as our server bandwidth is limited to 1MB/s

status "Clearing Old Backup"
cd $TMP
rm -Rf cms.old
mv cms cms.old
mkdir cms

status "Copying Remote Files"
# XXX - scp doesn't have an exclude option, so we have to be explicit here.
# I'd rather move this to config, but right now it's not worth the effort.
scp -rpCl $BANDWIDTH $SSH_TARGET:{public_html*,ssl,bin,etc,.[a-z]*} cms

status "Compressing Local Mirror"
tar cvzf $FILE cms

status "Copying Backup Tarball to $DEST"
scp $FILE $DEST

status "Done! Backup is at $DEST:$FILE"
