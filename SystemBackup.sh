#!/bin/bash

#arg1 output path

mountOutputPath="/var/systembackup/mountOutput.txt"
rsyncOutputPath=$1
#rsyncOutputPath="/mnt/STORAGE_ee7e0/owncloud_backup"
drive="STORAGE_ee7e0"
date=$(date +\%Y\%m\%d)

> $mountOutputPath
mount | grep $drive > $mountOutputPath

#echo Checking if $drive is mounted...
if [ ! -s $mountOutputPath ]
then
        #echo $drive is not mounted. I'll give it a shot...
        mount --all
        mount | grep $drive > $mountOutputPath
        if [ ! -s $mountOutputPath ]
        then
                #echo Still can't mount. Check connection... Bye.
                exit
        fi
fi

/usr/local/bin/pimatic.js stop
#echo $drive is mounted... Executing rsync command.
sleep 30
rsync -aAxXq --exclude-from=/var/rsync/rsyncExclusions.list /* $rsyncOutputPath/pimatic_rsync_temp
#echo Putting it in a tar...
tar -cvpzf $rsyncOutputPath/pimatic_backup_$date.tar.gz $rsyncOutputPath/pimatic_rsync_temp
#echo Taking a dump of mysql database.
sqlite3 /home/pi/pimatic-app/pimatic-database.sqlite .dump > $rsyncOutputPath/pimatic_dbbackup_$date.sql
#echo Starting pimatic again
/usr/local/bin/pimatic.js start
#echo Let me zip that for you...
gzip -f9 $rsyncOutputPath/pimatic_dbbackup_$date.sql # > /mnt/STORAGE_ee7e0/owncloud_backup/owncloud_dbbackup_$(date +\%Y\%m\%d).sql.gz