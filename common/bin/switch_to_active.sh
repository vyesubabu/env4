#!/bin/sh
#
# This script performs the switch over from the passive master to active mode
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI PIEPLU                                   Jan, 01  2014     #
#                                                                             #
###
##   ANY MODIFICATION OF THIS FILE ON CNMJAN/CNSJAN MUST BE COPIED TO THE OTHER
###
#   VERSION :								      #
#	* v1.0.0: 20150429						      # 
#		- Developped for CIPS TC SAT2 (v3.2.1)			      #
#									      #
#   TODO / IMPROVE:						  	      #
#	*	start slurm automatically
#	* 1. SYS/PART: system.mount.slash.usage : /cm/shared copy into /root
#	*	
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
# /common/bin/switch_to_active.sh
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#Execute remote command on the Onboard Administrator
executeCommandOnOA () {
	IP="$1"
	COMMAND="$2"
	sshpass -p "Password1234$" ssh Administrator@${IP} "$COMMAND" 2>/dev/null
	return $?
}

#Get the power state from the Onboard Administrator for a given Bay
isPowerOff () {
	BAY="$1"
	executeCommandOnOA "192.168.223.11" "show server status $BAY" | grep -q "Power: Off" 
	cr=$?
	return $cr
}

PowerOff () {
	BAY="$1"
	FORCE="$2"
	executeCommandOnOA "192.168.223.11" "POWEROFF SERVER $BAY $FORCE" 
	cr=$?
	return $cr
}

log () {
	echo "$1"
}

#number of check to verify that the server is down
NUMBER_RETRY=10
#duration between each retry
DURATION_RETRY=15

#Slurm path
SLURM_PATH="/cm/shared/apps/slurm/var/etc"

#Get the position of the bay to power off in the rack depending the hostname
MASTER_BAY_POSITION="-1"
if [ "$(hostname)" == "CNMJAN" ]
then
	MASTER_BAY_POSITION="13"
else
	MASTER_BAY_POSITION="5"
fi

#debug
#MASTER_BAY_POSITION=16

#Check the High Avaibility status
if cmha status | head -1 | grep -q "passive"
then
	log "$(hostname) is running in standby mode."
	if [ ! -e "/dev/mapper/Lun_NAS_Assim1" ]
		then
			log "restart iscsi services"
			/etc/init.d/iscsi restart
			sleep 5
			if [ ! -e "/dev/mapper/Lun_NAS_Assim1" ]
			then
				log "The iscsi disk /dev/mapper/Lun_NAS_Assim1 is not visible"
				log "Cannot switch in Active mode"
				exit 1
			fi
	fi
	if ! isPowerOff "$MASTER_BAY_POSITION"
	then
		log "Trying to do a graceful shutdown on the Active server (Bay position in the rack $MASTER_BAY_POSITION) - waiting $DURATION_RETRY seconds"
		#Perform a graceful shutdown
		PowerOff $MASTER_BAY_POSITION
		sleep $DURATION_RETRY
		for i in $(seq 1 $NUMBER_RETRY)
		do
			if ! isPowerOff "$MASTER_BAY_POSITION"
			then
				log "The Active server is still power on - waiting $DURATION_RETRY seconds $i/$NUMBER_RETRY"
				sleep $DURATION_RETRY
				if [ $i -eq $NUMBER_RETRY ]
				then
					#Force the shutdown
					log "The Active server is still power on... Force the shut-down - waiting $DURATION_RETRY seconds"
					PowerOff $MASTER_BAY_POSITION "FORCE"
					sleep $DURATION_RETRY
				fi
			else
				break
			fi
		done
	fi
	if isPowerOff "$MASTER_BAY_POSITION"
	then
		log "The Active server is power off."
		log "Start the process to switch in Active mode - execute the command \"cmha makeactive\" on $(hostname)"
		cmha makeactive
			sleep 30
			log "reboot \"compute01..compute32,CSOJAN,CSIJAN,CSSJAN,CSDJAN\" nodes"
			cmsh -c "device ; pexec -n compute01..compute32,CSOJAN,CSIJAN,CSSJAN,CSDJAN \"reboot\"" > /dev/null
			sleep 30
			log "Reset CSOJAN,CSIJAN,CSSJAN,CSDJAN"
			cmsh -c "device ; pexec -n CSOJAN,CSIJAN,CSSJAN,CSDJAN \"power reset\"" > /dev/null
			sleep 20
			log "Changing the slurm configuration"
			rm -f ${SLURM_PATH}/slurm.conf
			rm -f ${SLURM_PATH}/slurmdbd.conf
			ln -s ${SLURM_PATH}/slurm.conf.$(hostname) ${SLURM_PATH}/slurm.conf 
			ln -s ${SLURM_PATH}/slurmdbd.conf.$(hostname) ${SLURM_PATH}/slurmdbd.conf 
			ll ${SLURM_PATH}
			log "Please restart slurm services manually"
			log "/etc/init.d/slurm restart"
			log "/etc/init.d/slurmdbd restart"
			log "Please verify schedulers are down"

	else
		log "The script did not succeed to power off the Master Server. Please do it manually by pressing the power button and relaunch the script $0"
	fi
else
	log "Cannot switch in Active mode. The server is already in this mode"
fi
