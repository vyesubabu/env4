#!/bin/bash
#
# This script finds the rogue processes left running on nodes where no
# interactive connection is allowed (typically compute nodes)
#
# Developped for Bright 7.0 (uses pdsh)
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0: 20150806						      # 
#		- Change the ID list identification manner
#		- Rogue process killer init				      #
#									      #
#   TODO / IMPROVE:						  	      #
#	- to be adapted for Bright 6.1 (using pexec)                          #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

NODELIST=`cmsh -c "ds|grep compute" |awk '{print $1}'`

AUTOKILL="NO"

for NODE in $NODELIST; do

#	ROGUEPROCESS_ID=`cmsh -c "device use $NODE ; check rogueprocess -v|grep FAIL -A1| grep '[0-9]\*/'"| grep -o '[0-9]*'`

	cmsh -c "device use $NODE ; check rogueprocess -v | grep FAIL -A10 | grep '[0-9]\*/'"| grep -o '[0-9]*' > /tmp/tmp_out
	ROGUEPROCESS_ID=`cat /tmp/tmp_out  |paste -s - -|sed -e "s:/\*\(.*\)\*/:\1:g" -e "s:.*)::g" -e "s:,::g" -e "s:  \+: :g"`
	
	if [ ! -z "$ROGUEPROCESS_ID" ]; then
		echo "Some rogue process exists in $NODE with $ROGUEPROCESS_ID"
	else
		echo "No rogue process on $NODE"	
	fi
	
	echo ""

done


