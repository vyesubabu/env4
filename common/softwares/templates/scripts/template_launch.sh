#!/bin/bash
#--------init ENV-----------
. /etc/profile.d/modules.sh
module load taskcenter/sms

##########################################################
## 		EDIT HERE!!!
##########################################################

USERDIR=$HOME/TASK

## The NAME of the PACK for this task. (DO NOT INCLUDE PATH!)
## Will be downloaded locally
## in the temporary execution directory of the task. This file should 
## be generated through the make_task_tar.sh command (following a
## create_task_structure.sh command and proper editing)
PACK=TASK.tgz

## The Master script / executable within the PACK
MASTER=master.sh


##########################################################
##	 NO EDITING NECESSARY BELOW THIS LINE
##########################################################

. $COMMON_HOME/bin/cips_bash_functions.sh
exportcipsfunctions
cb_host         ## Host Banner
cb_start   	## Start Banner

## Activate Debug mode on integration server
if [ $HOSTNAME == "cipsinteg" ]; then 
	set -x
else # oper.q & others
	set +x
fi

## Check if DMT_PATH_EXEC is set
if [ -z "$DMT_PATH_EXEC" ]; then
	if [ ! -z "$USERDIR" ]; then
		DMT_PATH_EXEC=$USERDIR
	else
		echo "No USERDIR or DMT_PATH_EXEC is set. Aborting"
		exit 1
	fi
fi 

echo "#########################################################"
echo ""
echo "SOURCE DIRECTORY IS DMT_PATH_EXEC = $DMT_PATH_EXEC"
echo "WORKING DIRECTORY IS PWD = " $PWD
echo "DATE IS DMT_DATE_PIVOT = $DMT_DATE_PIVOT"
echo ""
echo "#########################################################"

## For automatic reporting of errors to Zabbix
function zabbix_sender {
    key=$1
    value=$2
    HOSTNAME=`hostname -s`
    Z=/usr/sbin/zabbix_sender
    if [ -z "$SHARED_HOME" ]; then
	export SHARED_HOME=/shared
    fi
    $Z -z zabbixsrv -s $HOSTNAME -k "$key" -o "$value" >> $SHARED_HOME/zabbix/logs/opertasks_crashes.log
}


## Set-up task directories
export TASK_MAIN=$PWD
export TASK_IN=$PWD/input
export TASK_OUT=$PWD/out
export TASK_RESOURCES=$PWD/resources
export TASK_BIN=$PWD/bin
export TASK_RUN=$PWD/run

## copy the PACK to workdir
cp $DMT_PATH_EXEC/${PACK} .

## untar the PACK
tar xfvz ${PACK}

## link all files in run directory
cd $TASK_RUN

## launch the MASTER script
$TASK_BIN/$MASTER 

if [ $? != 0 ]; then
	echo "Error(s) detected in MASTER script. Please see execution logs"
	echo "Aborting and sending to SMS..."
	exit 1
	smsabort
	#zabbix-sender taskcrasho
	zabbix_sender "cips.task.error" "The Following Task has crashed :  $PACK"
fi

echo "cd $TASK_MAIN"

## CIPS Task End Banner
cb_end		## End Banner
