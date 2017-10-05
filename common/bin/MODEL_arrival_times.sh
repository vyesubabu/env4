#!/bin/bash
#
# This script checks Data Advisory reception times
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Oct, 16  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.2: 20150415						      # 
#		- add: module load
#	* v1.0.1: 20141204						      # 
#		- AD variable ; AD=0132h
#	* v1.0.0: 20141016						      # 
#		- Init version						      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
MAINDIR=/home/sms/journal/sms/gad/moddb/

module load taskcenter/common

. $COMMON_HOME/bin/cips_bash_functions.sh

AD_REF="RUNCOMPLETED_013200"
AD_REF="RUNCOMPLETED_012000"

MODEL=$1
AD=$2

if [ -z "$AD" ];then
	AD=$AD_REF
fi

TODAY8=`date -u +"%Y%m%d"`
TODAY14=`date -u +"%Y%m%d%H%M%S"`
FMTDATE=`date14_to_fmt $TODAY14`

YESTERDAY14=`date -u --date="$TODAY GMT -24 hours" +"%Y%m%d%H%M%S"`
YESTERDAY8=`echo $YESTERDAY14 |cut -c1-8`

TWODAYSAGO14=`date -u --date="$TODAY GMT -48 hours" +"%Y%m%d%H%M%S"`
TWODAYSAGO8=`echo $TWODAYSAGO14 |cut -c1-8`



cd $MAINDIR

# check in yesterday's log first
echo "TWO DAYS AGO"
cat $TWODAYSAGO8 |grep $MODEL |grep "$AD"

echo

# check in yesterday's log first
echo "YESTERDAY"
cat $YESTERDAY8 |grep $MODEL |grep "$AD"

echo

# check in today's log second
echo "TODAY"
cat $TODAY8 |grep $MODEL |grep "$AD"

