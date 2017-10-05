#!/bin/bash
#
# This script fixes the structure of subdirs inside a task
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0: 20140101						      # 
#		-	init						      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

echo "Working in $PWD"

TASKLIST=`ls -1d T*`

echo "Fixing $TASKLIST..."

for task in $TASKLIST ; do
	cd $task
	for dir in bin input resources run out ; do
		[[ -d $dir ]] || mkdir -p $dir  ; touch $dir/README
	done
	/common/bin/make_task_tar.sh FORCE
	/common/bin/rephase_launchscripts.sh
	echo "done fixing $task"
	echo ""
	cd ..
done
	
