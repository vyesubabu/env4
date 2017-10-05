#!/bin/bash
#
# This script repacks some of the projects & their tasks in /share/apps/tasks
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTEUR: REMI MONTROTY                                   Oct, 20  2011     #
A
#                                                                             #
#   VERSION :								      #
#	* v1.2	: 20150203						  # 
#		- bugfix MODULEPATH + verif tasks
#	* v1.1	: 20131115						  # 
#		- for BMKG .. used to repack CHIMERE tasks
#	* v1.0								  # 
#		- Adding GRIDS to scan for various projects matching it       #
#									  #
#   LATEST MODIFICATIONS :					  	#
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  DO NOT USE IT 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#--------init ENV-----------
. /etc/profile.d/modules.sh
export MODULEPATH=/cm/shared/modulefiles:$MODULEPATH
module load use.own
module load taskcenter/common

MAINTASKDIR=/cm/shared/tasks/SAVES/operationaltasks/bmkg/CHIMERE
COMMON=/common/bin
MAINTASKDIR=/cm/shared/tasks/SAVES/operationaltasks/bmkg/WRFDA
MAINTASKDIR=/cm/shared/tasks/WRFDA/VERIFICATION
MAINTASKDIR=/cm/shared/tasks/WRFDA/
MAINTASKDIR=/cm/shared/tasks/CHIMERE.SMS
MAINTASKDIR=/cm/shared/tasks/RCC/LRF

cd $MAINTASKDIR
TASK_LIST=`ls -1d T_*/`
set -x
echo "processing tasklist $TASK_LIST"
#exit 0
for task in $TASK_LIST; do
	echo "Doing Task $task ... "
	cd $MAINTASKDIR/$task
	
	echo $COMMON/make_task_tar.sh FORCE
	$COMMON/make_task_tar.sh FORCE
	$COMMON/rephase_launchscripts.sh
done
