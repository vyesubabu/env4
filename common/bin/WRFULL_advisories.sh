#!/bin/bash
#
# This script checks Data Advisory reception times
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Oct, 16  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.1: 20141021						      # 
#		- Copy from ECMWF_arrival_times.sh 			      #
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
MAINDIR=/home/sms/journal/sms/gad/fromHPC/

. $COMMON_HOME/bin/cips_bash_functions.sh


TODAY8=`date -u +"%Y%m%d"`
TODAY14=`date -u +"%Y%m%d%H%M%S"`
FMTDATE=`date14_to_fmt $TODAY14`

YESTERDAY14=`date -u --date="$TODAY GMT -24 hours" +"%Y%m%d%H%M%S"`
YESTERDAY8=`echo $YESTERDAY14 |cut -c1-8`

TWODAYSAGO14=`date -u --date="$TODAY GMT -48 hours" +"%Y%m%d%H%M%S"`
TWODAYSAGO8=`echo $TWODAYSAGO14 |cut -c1-8`
MODEL_DEFAULT=REV3d12

MODEL=$1

if [ -z "$MODEL" ]; then
	MODEL=$MODEL_DEFAULT
fi

case $MODEL in 
	REV3d12|REV2d12) 
#		MODEL=REV3d12
		GRID=D01D02
		echo "Searching for domains D01D02 for SEA0300 and INDX0100"
		;;
	REV3d3|REV2d3) 
		GRID=D03
		echo "Searching for domains D03 for JAVA0030"
		;;
	*)
		echo "Unknown MODEL $MODEL... " 
		exit 1
		;;
esac


RUN00="2.......000000"
RUN12="2.......120000"


cd $MAINDIR

# check in yesterday's log first
#echo "TWO DAYS AGO"
#cat $TWODAYSAGO8 |grep $MODEL|grep $GRID |grep "WRFOUTDONE"

echo

# check in yesterday's log first
echo "YESTERDAY RUN00"
cat $YESTERDAY8 |grep $MODEL | grep $GRID|grep $RUN00 | grep "WRFOUTDONE"
echo "YESTERDAY RUN12"
cat $YESTERDAY8 |grep $MODEL | grep $GRID|grep $RUN12 | grep "WRFOUTDONE"

echo

# check in today's log second
echo "TODAY RUN00"
cat $TODAY8 |grep $MODEL | grep $GRID|grep $RUN00 | grep "WRFOUTDONE"
echo "TODAY RUN12"
cat $TODAY8 |grep $MODEL | grep $GRID|grep $RUN12 | grep "WRFOUTDONE"

