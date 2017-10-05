#!/bin/bash
#
# This script tests the various issues seen on the TaskCenter
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.1: 20150429						      # 
#		- Do not test services on the non-VSCHEDOP scheduler
#	* v1.0.0: 20150428						      # 
#		- add check on number of machines up
#		- Init for CSIJAN/CSOJAN/CSSJAN				      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function nodesup() {
	## Can only be launched on the master node

	resultup=0

	## test computing nodes
	NCOMPUTES_UP=`cmsh -c "device list"|grep compute|grep UP|wc -l`
	if [ $NCOMPUTES_UP -ne 32 ]; then
		echo "Some issue with at least one COMPUTE"
		let resultup=resultup+1
	elif [ $NCOMPUTES_UP -eq 0 ]; then
		echo "All computing nodes down!! "
		exit 1
	elif [ $NCOMPUTES_UP -lt 17 ]; then
		echo "Less than Half the cluster is up"
		let resultup=resultup+1
	elif [ $NCOMPUTES_UP -eq 32 ]; then
		echo "All computing nodes up"
		resultup=0
	fi

	## test schedulers
	NSCHEDULERS_UP=`cmsh -c "device list"|grep "CS[IOSD]*"|grep UP|wc -l`
	if [ $NSCHEDULERS_UP -ne 4 ]; then
		echo "Missing at least one scheduler (found $NSCHEDULERS_UP /4 up)... which should be up"
		let resultup=resultup+1
	fi
}

function crmstatuscheck() {
	NRESOURCES_STARTED=`crm status|grep Started|wc -l`
	NRESOURCES_COLOCATED=`crm status|grep Started|grep -o CS.JAN|sort -u | wc -l` 
	VSCHEDUP_HOST=`crm status|grep Started|grep -o CS.JAN|sort -u` 

	resultres=0
	if [ $NRESOURCES_STARTED -ne 4 ]; then
		echo "Did not find 4 Resources"
		let resultres=resultres+1
	fi
	if [ $NRESOURCES_COLOCATED -gt 1 ]; then
		echo "Resources found on more than one scheduler! please check, they should be colocated"
		let resultres=resultres+1
	elif [ $NRESOURCES_COLOCATED -eq 1 ]; then
		#resultres=0
		let resultres=resultres+0
	else 
		echo "NRESOURCES_COLOCATED=$NRESOURCES_COLOCATED .. "
		echo "No resources started on any of the two schedulers! Check crm status"
		let resultres=resultres+100
	fi
}


#set -x

set +x

RESULT=0

if [ "$HOSTNAME" == "CNMJAN" ] || [ "$HOSTNAME" == "CNSJAN" ]; then

	#~~ check number of nodes up
	nodesup

	netvault_manager=`ps -ef |grep nvpmgr|grep -v grep`

	if [ ! -z "$netvault_manager" ]; then
		resultne=0
	else
		echo "Netvault manager not running on $HOSTNAME"
		resultne=1
	fi
elif [ "$HOSTNAME" == "CSOJAN" ] || [ "$HOSTNAME" == "CSSJAN" ]; then


	#~~
	crmstatuscheck

	is_vschedop=`ip addr show |grep 172.19.22.17`
	if [ ! -z "$is_vschedop" ]; then
		echo "$HOSTNAME is VSCHEDOP"
		/etc/init.d/httpd status
		resultap=$?
		/etc/init.d/corosync status
		resultco=$?
		/etc/init.d/postgresql status
		resultpg=$?
		/etc/init.d/taskcenterd status &> /dev/null
		resulttc=$?
		if [ $resulttc -eq 0 ];then
			echo "taskcenterd status is running..."
		else
			echo "taskcenterd not running well..."
		fi

	else
		if [ ! -z "$VSCHEDOP_HOST" ]; then
			echo "$HOSTNAME is VSCHEDOP, not current host $HOSTNAME"
			echo "Not testing further"
		fi
	fi

elif [ "$HOSTNAME" == "CSIJAN" ] ; then

	/etc/init.d/taskcenterd status &> /dev/null
	resulttc=$?
	if [ $resulttc -eq 0 ];then
		echo "taskcenterd status is running..."
	else
		echo "taskcenterd not running well..."
	fi
	
fi

let RESULT=resultpg+resulttc+resultap+resultco+resultne+resultup

echo "Final result=$RESULT"
exit $RESULT
