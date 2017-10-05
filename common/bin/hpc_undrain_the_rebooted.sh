#!/bin/bash
#
# This script does stuff
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0: 20160323						      # 
#		- Automatically find the drained nodes that are UP
#			& undrains them					      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


NODES_DRAINED=`sinfo|grep drain|grep oper|  sed -e "s:.*compute::g" -e "s:,: :g" -e "s:-: :g" -e "s:\[::g" -e "s:\]::g"` 

NODES_UP=`cmsh -c ds| grep UP|grep compute|awk '{print $1}'| sed "s:compute::"` 


for nodeid in $NODES_DRAINED; do

	echo "check if drained node compute$nodeid is up"
	
	is_up=`echo $NODES_UP|grep -o $nodeid`
	
	if [ ! -z "$is_up" ]; then
		echo "Node is up. Undraining"
		cmsh -c "device use compute${nodeid} ; undrain  ; check schedulers"
	fi 

done

