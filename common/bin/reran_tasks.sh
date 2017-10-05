#!/bin/bash
#
# This script provides the number of restarted tasks by a USER today
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Oct, 14  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.1: 20150421						      # 
#		- bugfix: use grep --text since log may contain binary
#		- bugfix: build LOGLIST with integration + oper logs
#	* v1.0.0: 20141014						      # 
#		- Init version						      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
cd /cm/shared/apps/SMS/logs/smslogs

OPT=$1
OPT_DATE=$2

LOGLIST1=`ls -rt INTEGRATION/sms.*.log|tail -1`
LOGLIST2=`ls -rt OPER/sms.*.log|tail -1`
LOGLIST="$LOGLIST1 $LOGLIST2"
#echo $LOGLIST 

TODAY=`date -u +"%d.%m.%Y"`

MYRESTART=/tmp/restarted.$USER.$$

USER8=`echo $USER | cut -c1-8`

GREP="grep --text"

if [ ! -z "$OPT_DATE" ]; then
	TODAY=$OPT_DATE
fi

set -x
for log in $LOGLIST; do
	cat $log|$GREP force| $GREP $TODAY|$GREP $USER8 >> $MYRESTART
done

if [ "$OPT" == "ALL_USERS" ]; then
	ALLUSERS=/tmp/restarted.ALL_USERS.$$
	for log in $LOGLIST; do
		cat $log|$GREP force| $GREP $TODAY|$GREP -v sms >> $ALLUSERS
	done
	echo "Logging all users actions today $TODAY"
	cat $ALLUSERS	
	NRESTART=`cat $ALLUSERS|wc -l`
	echo ""
	echo "NRESTARTS=$NRESTART for $TODAY"
	echo "File is in $ALLUSERS"

else
	NRESTART=`cat $MYRESTART|wc -l`

	echo "User $USER has restarted $NRESTART tasks" 

	if [ $NRESTART -ne 0 ]; then
		echo "Do you want to see them? Y/N"
		read answer
		if [ "$answer" == "Y" ] ||  [ "$answer" == "y" ]; then
			cat $MYRESTART

		fi
	fi
	#Cleanup
	rm -f $MYRESTART


fi

