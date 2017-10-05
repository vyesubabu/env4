#!/bin/bash
#
# This script reemits data advisories if not sent by Data Center
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0: 20140922						      # 
#		- Add: SMSNODE_LIST for loop
#		- Init for JC SAT1					      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  [root@CNMJAN bin]# ./fake_run.sh
# Which RUNDATE do you want advisories to be sent for ? (YYYYMMDDHHMMSS)
# 20140922000000
# Which model do you want advisories to be sent for ?
# PWRFASSIM
# Which grid do you want advisories to be sent for ? INDX0100 SEA0300 JAVA0030 or ALL
# JAVA0030
# you have selected the following grids: JAVA0030
# Which FRMAX do you want advisories to be sent for ? (number HHHHMM or AUTO)
# AUTO
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function send_frcompleted()  {

	for SMSNODE in $SMSNODE_LIST; do
		echo "Sending DataAdvisory for $FR FRCOMPLETED"
		/common/bin/send_advisories.sh -m $MODEL -g $GRID -r $FR -s FRCOMPLETED -d $DMT_DATE_PIVOT
	done
}


GRID_LIST_REF="INDX0100 SEA0300 JAVA0030"
SMSNODE_LIST="172.19.22.18 172.19.22.17"




echo "Which RUNDATE do you want advisories to be sent for ? (YYYYMMDDHHMMSS)"
read DMT_DATE_PIVOT
echo "Which model do you want advisories to be sent for ?"
read MODEL
echo "Which grid do you want advisories to be sent for ? $GRID_LIST_REF or ALL"
read GRID_LIST_REQ
echo "you have selected the following grids: $GRID_LIST_REQ"
echo "Which FRMAX do you want advisories to be sent for ? (number HHHHMM or AUTO)"
read FRMAX

set -x

if [ "$GRID_LIST_REQ" == "ALL" ]; then

	GRIDLIST="$GRID_LIST_REF"
else
	GRIDLIST="$GRID_LIST_REQ"

fi

### DEFINE SENDING OPTIONS BASED ON GRID AND USER CHOICES
for GRID in $GRIDLIST; do 
	case $GRID in 
		SEA0300|INDX0100) 
		FRLIST=`seq 0 3 120|awk '{printf("%.4d00\n",$1)}'`
		;;
		JAVA0030) 
		FRLIST=`seq 0 1 72|awk '{printf("%.4d00\n",$1)}'`
		;;
		*)
		echo "WTH is this grid? $GRID"
		exit 1
		;;
	esac

###  SEND ADVISORIES AS LOOP or INDIVIDUAL
	case $FRMAX in
		AUTO)
		  for FR in $FRLIST ; do
			#~~ 
			send_frcompleted
		  done
		;;
		*)
			FR=FRMAX
			#~~ 
			send_frcompleted
		;;
	esac
	
done

