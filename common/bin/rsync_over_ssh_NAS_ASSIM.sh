#!/bin/bash

FILES2RSYNC=$1

if [ -z "$FILES2RSYNC" ]; then
	echo "Missing files2rsync.txt"
	exit 1
fi

OPTS="--exclude-from=/etc/rsync.exclude"
OPTS="--exclude '*(WRF/[Ompst]*|OUT/*)'"
OPTS="--exclude '*OUT/*'"
OPTS="--exclude '*WRF/[fimpst]*'  --exclude '*/OUT/*'  --exclude '*WPS*'"
OPTS="--exclude '*WRF/[fimpst]*'"

RSYNC=/usr/bin/rsync
if [ ! -f $RSYNC ];then
	echo "$RSYNC does not exist.."
	echo "which rsync returns : "`which rsync`
	
	echo "Do you wish to use that? [Y/N]"
	read answer
	if [ "$answer" == "Y" ]; then
		RSYNC=`which rsync`
	else
		echo "aborting.."
	fi
fi



## Archive the whole /etc dir of local machine to some target (rocks in /tmp)
SOURCE_DIR="/cm/shared"
TARGET_DIR="root@172.19.22.137:/mnt/VERBATIM/BACKUPS/SAT2/CNMJAN/cm/shared"

## To rsync contents of /scratch/WEX to /nas 
SOURCE_DIR="/scratch"
#if you use FILES-FROM you need to add "/WEX" to /nas since files are in relative path from /scratch/WEX
TARGET_DIR="/scratch2"

$RSYNC --compress --verbose --rsh=ssh --times --owner --group --ignore-times --links  --perms --recursive --size-only --force --numeric-ids $OPTS --files-from=$FILES2RSYNC $SOURCE_DIR $TARGET_DIR


