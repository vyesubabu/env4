#!/bin/bash
#
# This script does stuff
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2017     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0: 20170101						      # 
#		-							      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
case $HOSTNAME in
	CNMTBI|CNMGAS|CNSGAS)
		echo "On master $HOSTNAME .. continue"
	;;
	*)
		echo "Wrong machine to call this from $HOSTNAME ... try from master"
		exit 1
	;;
esac

NODELIST=`cmsh -c "device status "|grep -v switch|  awk '{print $1}'|grep -v $HOSTNAME|grep -v CNM` 

PARTITIONS="/home /scratch /common /cm/shared"

## on master
service nfs restart

for node in $NODELIST; do 

	for part in $PARTITIONS; do
		echo "Unmounting $part from $node"
		pdsh -w $node "umount -l $part"
	done

	echo "remount all partitions on $node"
	pdsh -w $node "mount -a && df -h"
done	
	
