#!/bin/bash
#
# This script performs the cleaning of the HOLDSPACE when disk space goes
# below a threshold (e.g. 50%)
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 03  2012     #
#                                                                             #
#   VERSION :								      #
#	* v2.0: 20131016						      # 
#		- Update for /scratch_fhgfs						      #
#	* v1.4: 20120324						      # 
#		- cosmetics						      #
#	* v1.3: 20120321						      # 
#		- clean_planification() added				      #
#	* v1.2: 20120214						      # 
#		- Add remove_wrfout function				      #
#	* v1.1								      # 
#		-percentage left after cleanup				      #
#		-removal of GME						      #
#	* v1.0								      # 
#		-first import  						      #
#									      #
#   LATEST MODIFICATIONS :					   	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  clean_holdspace.sh							      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

if [ "$LOGNAME" != "root" ]; then
	echo "Must be run as root, to create dirs. Aborting!"
	exit 1
fi
#HOLDSPACE=/share/scratch/SMS/sms/holdspace
#HOLDSAVE=/nfs/holdspace

## number of days to keep
NDAYS=0
# or alternatively number of minutes/hours to keep
NMINUTES=720

## minimum percentage of available disk space before cleaning is triggered
MIN_PERCENTAGE_HDD=50
#MIN_PERCENTAGE_HDD=75

. /common/bin/cips_bash_functions.sh 

SCRATCH=/scratch_fhgfs
cd $SCRATCH
PERCENTAGE_USED=`df -h . | awk '{print $5}'|tail -1 | sed "s:%::g"`
let PERCENTAGE_LEFT=100-PERCENTAGE_USED

## Define DIRLIST to clean
DIRLIST=`ls -1d $SCRATCH/WEX/*/`
DIRLIST=`ls -1d $SCRATCH/Aria/*/`
DIRLIST="$DIRLIST `ls -1d $SCRATCH/tmp/*/*`"
DIRLIST="$DIRLIST `ls -1d $SCRATCH/SMS/sms/workdir/*`"
DIRLIST2CLEAN=`echo $DIRLIST |sed 's: :\n:g'`
echo "DIRLIST=$DIRLIST"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#			FUNCTIONS
# 

## F1
remove_wrfout() {

  dir=$1
  NHOURS=$2

  if [ -z "$*" ]; then
	echo "usage: remove_wrfout DIR NHOURS"
  elif [ -z "$NHOURS" ]; then
	echo "Using default : NHOURS=6"
	NHOURS=6
  fi

  let NMIN=60*NHOURS
  cd $dir
  find . -name 'wrfout*' -mmin +$NMIN -exec rm -f {} \;
}
clean_planification() {

  dir=$1
  NDAYS=$2

  if [ -z "$*" ]; then
	echo "usage: clean_planification DIR NDAYS"
  fi
  if [ -z "$NDAYS" ]; then
	echo "Using default : NDAYS=7"
	NDAYS=7
  fi
  if [ -z "$dir" ]; then
	PLANIFDIR=/home/sms/journal/cips/ATMOSPHERIC_MODELS
	echo "Using default : PLANIFDIR=$PLANIFDIR"
	dir=$PLANIFDIR
  fi


#	set -x
  cd $dir
 echo "Cleaning old deployment xmls  from $PLANIFDIR"
 # find . -name 'T_*' -mtime +${NDAYS}
 echo " find . -name 'T_*' -mtime +$NDAYS #-exec rm -f {} \;"
  find . -name 'T_*' -mtime +$NDAYS
  #find . -name 'T_*' -mtime +$NDAYS -exec rm -f {} \;
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

if [ $PERCENTAGE_LEFT -lt $MIN_PERCENTAGE_HDD ]; then
	echo "We are low on disk space : only $PERCENTAGE_LEFT % left... Threshold at $MIN_PERCENTAGE_HDD %!"

	echo "Cleaning planification directory first"
	clean_planification


	for dir in $DIRLIST; do
	
		OLD_SUBDIRS=`nminutes_old_subdirs_in_dir $dir $NMINUTES`

		for d in $OLD_SUBDIRS; do

			echo "rm -rf $d"
		#	rm -rf $d


#			lastdir=`echo ${d##*/} | cut -c1-3`
#
#			## delete only subdirs that start with 201x, exec.* or tache_* 
#			if [ "${lastdir}" == "201" ] || [ "${lastdir}" == "exe" ] || [ "${lastdir}" == "tas" ] ; then
#				holdspace_indir=`echo $d|grep holdspace`
#
#				## for the empty dir removal
#				echo "rm -rf $d"
#				#rm -rf $d
#			fi
			
		done
	done
	PERCENTAGE_USED=`df -h . | awk '{print $5}'|tail -1 | sed "s:%::g"`
	let PERCENTAGE_LEFT=100-PERCENTAGE_USED
	echo "After cleaning, PERCENTAGE LEFT is now $PERCENTAGE_LEFT % left... Threshold at $MIN_PERCENTAGE_HDD %!"
else
	echo "Sufficient disk space remaining: we are at $PERCENTAGE_LEFT % left... Threshold at $MIN_PERCENTAGE_HDD %!"
	echo ""
	echo "NO REQUIRED CLEANING FOR $DIRLIST2CLEAN"
	exit 0
fi



