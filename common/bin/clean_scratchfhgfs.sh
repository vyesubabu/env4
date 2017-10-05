#!/bin/bash
#
# This script cleans /scratch_fhgfs
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Apr, 09  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.2: 20140526						      # 
#		- Add: 
# find_prefix met_em DELETE 2
# find_prefix HGFS DELETE 2
# find_prefix wrfbdy DELETE 2
# find_prefix wrfvar DELETE 2
# find_prefix wrfinput DELETE 2
#	* v1.0.1: 20140415						      # 
#		- Mod: revise NDAYS for WRFOUT (since cleanup frees only 148Go)
#	find_prefix WPS DELETE 2
#	find_prefix wrfout DELETE 2
#	find_prefix wrfprs DELETE 4
#	goes to 1,1,2: frees 266Go
#
#	* v1.0.0: 20140409						      # 
#		- Init for Impmaster					      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

NDAYS_OLD="1"
MAXDAYS=5
LOG_AND_DEL="YES"
LOG_AND_DEL="NO"

XARGS="xargs --no-run-if-empty"

function find_prefix(){
	prefix=$1
	## over-ride deletion with "DELETE"
	DEL_THIS=$2
	## over-ride number of days to find with value of 3rd argument
	NDAYS_THIS=$3
	if [ -z "$NDAYS_THIS" ]; then
		NDAYS_THIS=$NDAYS_OLD
	fi
	set +x
	
	echo "finding files $prefix older than $NDAYS_THIS days ..."
	SIZE=`find . -name "${prefix}*" -mtime +${NDAYS_THIS} | $XARGS du -shcx | tail -1`
	if [ "$LOG_AND_DEL" == "YES" ] || [ "$DEL_THIS" == "DELETE" ]; then
		echo "Removing files $prefix for a size of $SIZE"
		find . -name "${prefix}*" -mtime +${NDAYS_THIS} | $XARGS rm -rf
	else	
		echo "Not deleting files $prefix worth a size of $SIZE"
		
	fi
}

################## MAIN

cd /scratch_fhgfs/WEX
find_prefix postprd DELETE 1
find_prefix wrfrst DELETE 1
find_prefix WPS DELETE 1
find_prefix wrfout DELETE 1
find_prefix wrfprs DELETE 2
find_prefix met_em DELETE 2
find_prefix HGFS DELETE 2
find_prefix wrfbdy DELETE 2
find_prefix wrfvar DELETE 2
find_prefix wrfinput DELETE 2

SIZE=`find . -mtime +$MAXDAYS | $XARGS du -shcx | tail -1`
echo "Removing files older than $MAXDAYS for size of  $SIZE"
find . -mtime +$MAXDAYS | $XARGS rm -rf
