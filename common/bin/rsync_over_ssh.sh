#!/bin/bash
OPTS="--exclude-from=/etc/rsync.exclude"

RSYNC=/usr/bin/rsync
SSH_OPTS="--rsh=ssh --compress"
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
SOURCE_DIR="/etc"
TARGET_DIR="root@rocks:/tmp"

## To rsync $COMMON/bin from remote site to here:
SOURCE_DIR="/home/montrotyr/WORK/2012/DEMO_CASSIDIAN/*"
TARGET_DIR="/media/WTF/DEMO_CASSIDIAN"

## To rsync 
SOURCE_DIR="/scratch/Development_Environment/v3.2.1-SAT2_INDO/cmsharedcfg/modulefiles/*"
TARGET_DIR="/cm/shared/modulefiles"

## To rsync prior to explosion of /cm/shared
SOURCE_DIR="/cm/shared/*"
TARGET_DIR="/mnt/cm_shared"


## To rsync prior to explosion of /cm/shared
SOURCE_DIR="/home/*"
TARGET_DIR="/mnt/home"

## to phase v3.2.1 of SCDE into impmaster
OPTS="--exclude 'intel*'"
SOURCE_DIR="/scratch/Development_Environment/v3.2.1-SAT2_INDO/cmsharedapps/*"
TARGET_DIR="root@10.0.0.201:/cm/shared/client_config/apps"

## To rsync prior to explosion of /cm/shared
SOURCE_DIR="/home/*"
TARGET_DIR="/home2"
SOURCE_DIR="/scratch/*"
TARGET_DIR="/scratch2"
SOURCE_DIR="/cm/shared/*"
TARGET_DIR="/cm/shared2"
#remove ssh for this one, as well as compression
SSH_OPTS=""

#$RSYNC --compress --verbose --rsh=ssh --times --owner --group --ignore-times --links  --perms --recursive --size-only --delete --force --numeric-ids $OPTS $SOURCE_DIR $TARGET_DIR
$RSYNC --verbose ${SSH_OPTS} --progress --times --owner --group --ignore-times --links  --perms --recursive --size-only  --force --numeric-ids $OPTS $SOURCE_DIR $TARGET_DIR


