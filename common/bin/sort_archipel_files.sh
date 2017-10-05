#!/bin/bash
#
# This script sorts & cleans ARCHIPEL incoming data
#
# Each time $MAX_DISK_USE is reached on local drive, we remove files older than
# $NDAYS
#
# Works either with no argument or with a specific dir given as argument :
# it then only processes that dir 
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Oct, 27  2012     #
#                                                                             #
#   VERSION :								      #
#	* v1.3.4 : 20130315						      # 
#		- find .  instead of ls 
#	* v1.3.3 : 20130121						      # 
#		- Comment: /tmp/sortdir.$$ (useless)			      #
#	* v1.3.2 : 20121207						      # 
#		- Add: LOCK file for incrontab multiple launches	      #
#		- Add: find -mtime +$days (without + works unproperly)	      #
#	* v1.3.1 : 20121130						      # 
#		- Delete: archipel dir by Eric's PUMA			      #
#	* v1.3 : 20121126						      # 
#		- Add: jpg files older than 1 day deletion		      #
#		- Mod: 10days max					      #
#	* v1.2 : 20121120						      # 
#		- Add: ascat sorting					      #
#	* v1.1 : 20121107						      # 
#		- Add: specific dir as argument				      #
#	* v1.0 : 20121027						      # 
#		- init							      #
#									      #
#   LATEST MODIFICATIONS :					  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  /common/bin/sort_archipel_files.sh
#
# or
#
#  /common/bin/sort_archipel_files.sh /scratch/data/archipel/meteosat-highrate
#
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

SPECIFICDIR=$1

LOCKNAME=sort_archipel_files.LOCK
LOCK=/tmp/$LOCKNAME

# Avoid deadlocks where a LOCK file is never destroyed 
# by forcing deletion every 15 min
find_and_deleteOldLocks=`find /tmp -type f -mmin +15 -name "$LOCKNAME" -exec rm -f '{}' \;`

if [ -f $LOCK ]; then 
	echo "Already processing. exit gracefully"
	exit 0
else
	touch $LOCK
fi
	
ARCHIPELDIR=/scratch/data/archipel

NDAYS=7
MAX_DISK_USE=50

function sortdir() {
	MYDIR=$1

	if [ -d $MYDIR ] && [ ! -z "$MYDIR" ]; then
		cd $MYDIR
		echo "Sorting incoming files in $MYDIR"
		
		## This command lists only files in first level recursiveness (ie current dir & no subdir)
		export FL=`find . ! -name . -prune -type f |sed "s:^./::"`

		#echo $FL >> /tmp/sortdir.$PPID

		for f in $FL; do
			five=`echo $f | cut -c1-5`
			case $five in
				"ascat") 
				DATE=`echo $f | awk 'BEGIN { FS = "_" }  {print $2}'`
				;;
				"H-000"|"L-000") 
				DATE=`echo $f | awk 'BEGIN { FS = "-" }  {print $7}'|cut -c1-8`
				;;

				*)
				DATE=`echo $f | awk 'BEGIN { FS = "." }  {print $3}'`
				;;
			esac

			[ -d $DATE ] || mkdir -p $DATE
			# assign latest to latest (NOT to STORAGEDIR, as we may be receiving old files)
			latest=`find . -type d -name "201*" |tail -1`
			rm -f latest
			ln -sf $latest latest

			# MOVE
			mv $f $DATE
		done
	else
		echo "No such dir $MYDIR"
		exit 1
	fi
}

if [ ! -z "$SPECIFICDIR" ] && [ -d $SPECIFICDIR ]; then

	#~~
	sortdir $SPECIFICDIR

	## debug
	#echo $FL | mail -s "$SPECIFICDIR now sorted" montroty.remi@gmail.com

else

set -x
	# get directories list
	cd $ARCHIPELDIR
	DL=`ls -1d */`

	for DIR in $DL; do

		#~~
		sortdir $ARCHIPELDIR/$DIR
		
	done

## Pre-emptive cleanup
	cd $ARCHIPELDIR
	PercentageDiskUse=`df -hv .|tail -1|awk '{print $5}'|sed "s:%::"`

	echo "Disk use= $PercentageDiskUse . Threshold at $MAX_DISK_USE"

	if [ $PercentageDiskUse -ge $MAX_DISK_USE ]; then 
		
		List_and_Delete_LastWeekFiles=`find . -type f -mtime +$NDAYS -exec rm -f '{}' \;`
		echo "We've deleted files older than $NDAYS days"
		
		find . -type f -name '*.jpg' -mtime +1 -exec rm -f {} \;
		echo "We've deleted JPG files older than 1 day"

		if [ -d $ARCHIPELDIR/archipel ]; then
			echo "Wrong archipel subdir in $ARCHIPELDIR !!"
			rm -rf $ARCHIPELDIR/archipel
		fi

		NewPercentageDiskUse=`df -hv .|tail -1|awk '{print $5}'|sed "s:%::"`
		echo "New Disk use= $NewPercentageDiskUse . Threshold at $MAX_DISK_USE"
	else
		#List_LastWeekFiles=`find . -type f -mtime $NDAYS `
		NFILES=`find . -type f -mtime +$NDAYS |wc -l `
		List_and_Delete_emptyDirs=`find . -type d -empty -mtime +$NDAYS -exec rmdir '{}' \;`
		echo "We've deleted empty directories older than $NDAYS days"

		if [ ! -z "$NFILES" ];then
			echo "There were $NFILES files older than $NDAYS days"
		else
			echo "No files older than $NDAYS days"
		fi
	fi
fi

echo "Releasing LOCK $LOCK"
rm -f $LOCK
