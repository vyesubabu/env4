#!/bin/bash
#
# This script cleans the /scratch_fhgfs/WEX directory
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2013     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.4: 20150601						      # 
#		- Mod: add rsl.error.0000 saves 
#	* v1.0.3: 20141020						      # 
#		- Mod: remove commented out "touch" of geogrid files
#		- Add: Additional cleanup /scratch_fhgfs/TASKS_OUTPUT/MODELS 
#		(2 days retention since data already in Data Center)
#		- Add: remove empty dirs in /scratch_fhgfs at the end of cleaning
#	* v1.0.2: 20140926						      # 
#		- Add: Additional cleanup wrfprs + wrfinput + wrfvar
#		-  Additional cleanup made for TASKS_OUTPUT & GFS
#		-  user $XARGS
#	* v1.0.1: 20131203						      # 
#		-  Hardcore cleanup added
#		-  Adaptative cleaning for Aria.SMS
#	* v1.0.0: 20131022						      # 
#		-  Start logging modifications
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

set -x 

MAX_PERCENTAGE_USED_ACCEPTED=70
MAX_PERCENTAGE_USED_ACCEPTED=85

XARGS="/usr/bin/xargs --no-run-if-empty"
cd /scratch_fhgfs/WEX || exit 1

## Save some files
# save geophysical fields
echo "Finding geogrid files & touching them"
find . -type f -name "geo_em.d0*.nc" | $XARGS touch 

# wrfinfo files
WRFINFO_TGZ=`date +%Y%m%d%H%M`_wrfinfo.tgz 
WRF_EXEC_LOGS_TGZ=`date +%Y%m%d%H%M`_rsl_files.tgz 

echo "Saving .wrfinfo files to /cm/shared/apps/WRF/LOGS"
find . -name .wrfinfo | $XARGS tar cvzf $WRFINFO_TGZ
echo "Saving rsl.error.0000 files to /cm/shared/apps/WRF/LOGS"
find . -name rsl.error.0000 | $XARGS tar cvzf $WRF_EXEC_LOGS_TGZ
mv $WRFINFO_TGZ /cm/shared/apps/WRF/LOGS
mv $WRF_EXEC_LOGS_TGZ /cm/shared/apps/WRF/LOGS

## Remove files older than 4 days
echo " Remove any files older than 4 days"
find . -mtime +4 -exec rm -rf {} \;

# Remove WPS Scories
#find . -name 'FILE*' -mtime +1|$XARGS rm -rf
find . -name 'met*.nc' -mtime +1|$XARGS rm -rf 
find . -name "FILE*" -mmin +120|$XARGS rm -rf

### Remove WRF scories
find . -name "FILE*" -mmin +120|$XARGS rm -rf
# Remove postprd directories older than 4h
find . -type d -name "postprd.*" -mmin +240 |$XARGS rm -rf
# WRFOUT older than 15h 
find . -name "wrf[oriv]*" -mmin +900|$XARGS rm -rf
## delete pressure files older than 10h
find . -name "wrf[p]*" -mmin +600|$XARGS rm -rf
# find all the directories YYYYMMDD/HHMM older than 18h 
find /scratch_fhgfs/WEX -type d -mmin +1080 -maxdepth 3 -mindepth 3|xargs rm -rf


## Bz2 files
find . -name "*.bz2" -mmin +600 > /tmp/bz2files
echo "find bz2 list in /tmp/bz2files"

########### CLEAN TMP for task_localtest
echo "Cleaning /scratch_fhgfs/tmp"
find /scratch_fhgfs/tmp/ -mmin +1440 |$XARGS rm -rf

## Clean SMS workdir after 2 days (leave previous day, if one needs to debug)
#echo "Cleaning /scratch_fhgfs/SMS/workdir"
#find /scratch_fhgfs/SMS/workdir/SLURM  -mmin +2880 | $XARGS rm -rf

## Clean Aria
echo "Cleaning /scratch_fhgfs/Aria"
find /scratch_fhgfs/Aria/ -type f -mtime +2 |$XARGS rm -rf
find /scratch_fhgfs/Aria.SMS/ -type f -mmin +1440 |$XARGS rm -rf
ARIA_DAY_TASKDIR=/scratch_fhgfs/Aria.SMS/CHIMERE/INDO/MRES/tmp-LS
find $ARIA_DAY_TASKDIR -name "201*" -type d -mtime +0 -maxdepth 1|sort -n|$XARGS rm -rf
ARIA_TRNASFERT=/scratch_fhgfs/Aria.SMS/TRANSFERT
find $ARIA_TRANSFERT -mmin +720 -name "*.nc" | $XARGS rm -f


## Clean GFS
echo "Cleaning /scratch_fhgfs/WEX/GFS"
find /scratch_fhgfs/WEX/GFS/ -type f -mmin +1440 |$XARGS rm -rf

## Clean TASKS_OUTPUT
echo "Cleaning /scratch_fhgfs/TASKS_OUTPUT"
find /scratch_fhgfs/TASKS_OUTPUT/ -type f -mmin +1440 |$XARGS rm -rf


## Remove empty directories (no space used but cleaner)
find /scratch_fhgfs -empty |$XARGS rm -rf

cd /scratch_fhgfs
PERCENT_USE=`df -h . |awk '{print $5}'|grep -v Use|sed "s:%::g"`

if [ $PERCENT_USE -ge $MAX_PERCENTAGE_USED_ACCEPTED ]; then

	echo "Using way too much space on /scratch_fhgfs : $PERCENT_USE % > $MAX_PERCENTAGE_USED_ACCEPTED % "
	echo "Proceeding to hardcore cleanup"

	find . -name "wrf[or]*" -mmin +600|$XARGS rm -rf
		
	find /scratch_fhgfs/Aria -type f -mtime +1 |$XARGS rm -rf
	find /scratch_fhgfs/Aria.SMS/ -type f -mtime +0 |$XARGS rm -rf


	echo "Size of all wrfprs files:"
	find . -name 'wrfprs*' -ls | awk '{total += $7} END {print total/1024/1024/1024" GB"}'
	
	if [ $PERCENT_USE -ge 95 ]; then
		find /scratch_fhgfs -mmin +300 |grep wrfout|grep "00:00$"
	fi
fi
