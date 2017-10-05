#!/bin/bash
HOLDSPACE=/share/scratch/SMS/sms/holdspace
HOLDSAVE=/shared/holdspace
WORKDIR=/share/scratch/SMS/sms/workdir

## Max minutes after which the task is deemed old
NMINUTES=720
NDAYS=0
MIN_PERCENTAGE_HDD=50

. /share/common/bin/cips_bash_functions.sh 

SCRATCH=/share/scratch
cd $SCRATCH
PERCENTAGE_USED=`df -h . | awk '{print $5}'|tail -1 | sed "s:%::g"`
let PERCENTAGE_LEFT=100-PERCENTAGE_USED

## Define OLDTASK to clean


if [ $PERCENTAGE_LEFT -lt $MIN_PERCENTAGE_HDD ]; then
	echo "We are low on disk space : only $PERCENTAGE_LEFT % left... Threshold at $MIN_PERCENTAGE_HDD %!"
	for dir in $DIRLIST; do
		#cd $HOLDSPACE/$dir
		OLD_SUBDIRS=`ndays_old_subsdirs_of_dir $dir $NDAYS`
		for d in $OLD_SUBDIRS; do
			lastdir=`echo ${d##*/} | cut -c1-3`
			## delete only subdirs that start with 201x 
			if [ "${lastdir}" == "201" ] || [ "${lastdir}" == "exe" ] ; then
				holdspace_indir=`echo $d|grep holdspace`
				if [ "$HOSTNAME" == "rocks.mfi.fr" ] && [ ! -z "$holdspace_indir" ]; then
					branch=`echo ${d##*holdspace/}`
					mkdir -p $HOLDSAVE/$branch
					echo "mv $d/* $HOLDSAVE/$branch"
					mv $d/* $HOLDSAVE/$branch
				fi
				echo "rm -rf $d"
				rm -rf $d
			fi
			
		done
	done
else
	echo "Sufficient disk space remaining: we are at $PERCENTAGE_LEFT % left... Threshold at $MIN_PERCENTAGE_HDD %!"
	echo ""
	echo "NO REQUIRED CLEANING FOR $DIRLIST2CLEAN"
	exit 0
fi
