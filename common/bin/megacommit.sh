#!/bin/bash
#
# This script prepares all the modifications for commiting to GIT
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2013     #
#                                                                             #
#   VERSION :								      #
#	* v3.2.0-rev1: 20140902						      # 
#		- Mod: @BMKG ; do OBS TASKS from bin/ , not WRFDA/scripts
#	* v3.2b2-rev8: 20140716						      # 
#		- Mod: T_SAT_COLOR_COMPOSITE to replace T_SAT_MTSAT_CC
#	* v3.2b2-rev7: 20140612						      # 
#		- Add: T_SAT_MTSAT_CC
#	* v3.2b2-rev7: 20140611						      # 
#		- Add: T_OCN_TCHP
#	* v3.2b2-rev6: 20140320						      # 
#		- Add: T_ATM_UPDATE_LOW_BC
#	* v3.2b2-rev5: 20140318						      # 
#		- Add: ALLOBS_TO_LITTLER
#	* v3.2b2-rev4: 20140317						      # 
#		- Add: 2 GFSFEED tasks
#	* v3.2b2-rev3: 20140313						      # 
#		- Add: T_ATM_TEST_METGRID (for Hot Start)		      #
#	* v3.2b2-rev2: 20140310						      # 
#		- Add: T_ATM_UNGRIB 					      #
#		- Add: T_ATM_GEOGRID 					      #
#	* v3.2b2-rev1: 20140310						      # 
#		- Add: T_ATM_WATCHER 					      #
#		- Add: T_ATM_MODELRUN					      #
#	* v1.0.0: 20130101						      # 
#		- Init							     #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

LATEST_MEGACOMMIT=/tmp/latest_megacommit.txt
 
TASKDIR_LIST=" /cm/shared/tasks/WRFDA/T_OBS_METAR_TO_LITTLER 
/cm/shared/tasks/WRFDA/T_OBS_SYNOP_TO_LITTLER
/cm/shared/tasks/WRFDA/T_OBS_TEMP_TO_LITTLER
/cm/shared/tasks/WRFDA/T_OBS_ALLOBS_TO_LITTLER
/cm/shared/tasks/WRF/P_ATM_WRF_SLURM/T_ATM_NDOWN
/cm/shared/tasks/WRF/P_ATM_WRF_SLURM/T_ATM_UNIPOST 
/cm/shared/tasks/WRF/P_ATM_WRF_SLURM/T_ATM_REAL 
/cm/shared/tasks/WRFDA/T_ATM_UPDATE_LAT_BC
/cm/shared/tasks/WRFDA/T_ATM_UPDATE_LOW_BC
/cm/shared/tasks/WRF/P_ATM_WRF_SLURM/T_ATM_MODELRUN 
/cm/shared/tasks/WRF/P_ATM_WRF_SLURM/T_ATM_WATCHER 
/cm/shared/tasks/WRF/P_ATM_WRF_SLURM/T_ATM_UNGRIB 
/cm/shared/tasks/WRF/P_ATM_WRF_SLURM/T_ATM_GEOGRID 
/cm/shared/tasks/WRF/P_ATM_WRF_SLURM/T_ATM_METGRID
/cm/shared/tasks/WRF/P_ATM_WRF_SLURM/T_ATM_TEST_METGRID 
/cm/shared/tasks/WRF/P_ATM_GFS_FEED/T_ATM_METGRID_GFSFEED
/cm/shared/tasks/WRF/P_ATM_GFS_FEED/T_ATM_UNGRIB_GFSFEED
/cm/shared/tasks/OCN/T_OCN_TCHP
/cm/shared/tasks/SAT/P_SAT_COLOR_COMPOSITE/T_SAT_COLOR_COMPOSITE
/cm/shared/tasks/WRFDA/T_OBS_OBSPROC"

WRFDA_scripts=/cm/shared/apps/WRFDA/scripts/

function select_script() {
	case $TASK in
		T_OBS_SYNOP_TO_LITTLER|T_OBS_METAR_TO_LITTLER|T_OBS_TEMP_TO_LITTLER|T_OBS_ALLOBS_TO_LITTLER)
			REALNAME=`echo $TASK| awk 'BEGIN {FS="_"} {print $3}'`
			#script=$WRFDA_scripts/transform_$REALNAME.scr
			#script=../scripts/transform_$REALNAME.scr
			script=$DIR/bin/transform_$REALNAME.scr
			;;
		T_OBS_OBSPROC)
			script=$WRFDA_scripts/run_OBSPROC.scr
			;;
		T_ATM_UPDATE_LAT_BC|T_ATM_UPDATE_LOW_BC)
			#REALNAME=${TASK##*_}
			REALNAME=${TASK##*T_???_}
			script=/cm/shared/tasks/WRFDA/$TASK/bin/SetAll.EXPNAME.sh.$REALNAME
			;;
		T_ATM_NDOWN|T_ATM_UNIPOST|T_ATM_REAL|T_ATM_MODELRUN|T_ATM_WATCHER|T_ATM_UNGRIB|T_ATM_GEOGRID|T_ATM_METGRID|T_ATM_TEST_METGRID)
			REALNAME=${TASK##*T_???_}
			script=/cm/shared/tasks/WRF/P_ATM_WRF_SLURM/$TASK/bin/SetAll.EXPNAME.sh.$REALNAME
			;;
		T_ATM_UNGRIB_GFSFEED|T_ATM_METGRID_GFSFEED)
			REALNAME=${TASK##*T_???_}
			script=/cm/shared/tasks/WRF/P_ATM_GFS_FEED/$TASK/bin/SetAll.EXPNAME.sh.$REALNAME
			;;
		T_OCN_TCHP)
		## without project name in dir name
			FAMILY=`echo $TASK | awk 'BEGIN { FS="_" } { print $2}'`
			script=/cm/shared/tasks/$FAMILY/$TASK/bin/master.sh
			;;
		T_SAT_COLOR_COMPOSITE)
		## with project in dir name (doesnt match $FAMILY/$TASK)
			FAMILY=`echo $TASK | awk 'BEGIN { FS="_" } { print $2}'`
			script=$DIR/bin/master.sh
			;;
		*)
		echo "Task $TASK unknown ... exiting"
		;;
	esac
}
	 

echo "Processing $TASKDIR_LIST"

echo "Latest megacommit: "`date -u ` >> $LATEST_MEGACOMMIT

for DIR in $TASKDIR_LIST ; do

	cd $DIR
	TASK=`basename $DIR`
	select_script $TASK
	latest_modified_file=`ls -rt1|tail -1`

	if [ "$latest_modified_file" == "$TASK.tgz" ]; then	
		echo "Task pack $TASK.tgz is latest modified file. Not touching"
	else
		/common/bin/make_task_tar.sh FORCE
	fi

	git status .| grep  -q "nothing to commit"
	anything2commit=$?

	if [ $anything2commit -ne 0 ]; then	
		git add . -u 
		git add $script
		version=`/common/bin/get_script_version.sh $script`

		git commit -m "$version $TASK"

		echo "echo $TASK $script $version" >> $LATEST_MEGACOMMIT
	else
		echo "Nothing to commit in $DIR"
	fi

done
