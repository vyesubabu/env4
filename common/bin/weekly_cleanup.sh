#!/bin/bash
#
# This script cleans SMS garbage logs and outdated files 
#
# Logs that are meant to be kept are dealt with by logrotate. See in 
# /cm/shared/client_config/crontab
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Apr, 27  2016     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0: 20160427						      # 
#		- cleanup the daily task logs				      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

NDAYS_RETENTION=60

## Find all the old task logs / planifications & remove them

function clear_old_logs() {

	DIR=$1
	if [ ! -z "$DIR" ] ; then
		echo "cleaning $DIR ..."
		cd $DIR
		find . -mtime +${NDAYS_RETENTION} -type f | xargs rm -f
	fi
}


#~~  clear OPER & INTEG planifications files
clear_old_logs /cm/shared/apps/SMS/logs/OPER/cips/

clear_old_logs /cm/shared/apps/SMS/logs/INTEGRATION/cips/
