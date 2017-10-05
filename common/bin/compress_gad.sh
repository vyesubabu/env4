#!/bin/bash
#
# This script compresses & cleans GAD dir
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Sept, 15  2014    #
#                                                                             #
#   VERSION :								      #
#	* v1.0.2: 20151012						      # 
#		- Add a conditional test for HOSTNAME: dont compress if not 
#		  known or not OPER
#	* v1.0.1: 20150202						      # 
#		-  bugfix for pbzip module load in crontab
#	* v1.0.0: 20140915						      # 
#		-  Init version 					      #
#		-  PBZIP2 module load
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
. /etc/profile.d/modules.sh
export MODULEPATH=/cm/shared/modulefiles:$MODULEPATH


MAINDIR=/home/sms/journal/sms/gad
STORAGEDIR=/home/sms/journal/sms/storage/gad
NPROC=`cat /proc/cpuinfo |grep processor|wc -l`

KEEP_LIVE_FOR_NDAYS=7
DELETE_AFTER=60

module load pbzip2/1.1.6


## get status
STATUS=`/common/bin/get_status.sh`

case $HOSTNAME in 
	CSSJAN|CSOJAN)
		if [ "$STATUS" != "OPER" ]; then
			echo "on $HOSTNAME, status = $STATUS ... exiting"
			exit 0
		else
			echo "on $HOSTNAME, status = $STATUS ... Proceeding"
		fi
		;;
	CSIJAN|CSRJAN)
		echo "No specific condition for removal on $HOSTNAME. Proceeding"
	 	;;

	*) 
		echo "$HOSTNAME doesnt hold a scheduler?? exit" 
		exit 1
		;;
esac

echo "on host $HOSTNAME, starting compressing"


cd $MAINDIR
echo ".. in $MAINDIR..."
find -type f -mtime +${KEEP_LIVE_FOR_NDAYS}| grep -v bz2| xargs --no-run-if-empty pbzip2 -j$NPROC

cd $STORAGEDIR
echo ".. in $STORAGEDIR..."
find -type f -mtime +${KEEP_LIVE_FOR_NDAYS}| grep -v bz2| xargs --no-run-if-empty pbzip2 -j$NPROC

echo "on host $HOSTNAME, starting deletion"
echo ".. in $STORAGEDIR..."
#find -type f -mtime +${DELETE_AFTER}|xargs rm -f
FL=`find -type f -name "*.bz2" -mtime +${DELETE_AFTER}`
echo "about to delete $FL"
if [ ! -z "$FL" ]; then
rm -f $FL
fi


