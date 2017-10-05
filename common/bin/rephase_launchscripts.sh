#!/bin/bash
#
# This script resets the PATHs and PACK variables in wrapper scripts
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Dec, 22  2011     #
#                                                                             #
#   VERSION :								      #
#	* v1.1.1: 20151019						      # 
#		- Bug: when 2 packs are detected in task main dir, exit
#		- Bug: when 2 packs are detected in subdirs, restrain the
#		find command to local
#	* v1.1								      # 
#		- Bug when two directories are used, one being linked to 
#		another : 2 PACKS are there => crash launch.sh                #
#	* v1.0								      # 
#		- Original version for launch.sh & task_localtest.sh          #
#									      #
#   LATEST MODIFICATIONS :					  	      #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#                                          #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
set -x

## Find local dir values for PACK, USERDIR
HOST=`hostname`
if [ "$HOST" == "cipsschedop" ] || [ "$HOST" == "cipsschedstdby" ]; then
	PNAMETNAME=`pwd| sed "s:.*/P_\(.*\):P_\1:"`
	FAMILY=`echo $PNAMETNAME |cut -c3-5`
	USERDIR=/common/task/$FAMILY/$PNAMETNAME
else
	USERDIR=`pwd`
fi

PACK=`find . -maxdepth 1 -name 'T_*.tgz'`

NPACK=`echo $PACK | wc -w`

if [ $NPACK -ne 1 ]; then
	echo "Some issue with PACK: $NPACK found... list: $PACK"
	echo "Fix it & continue please"
	exit 1
fi

TODAY=`date -u +%Y%m%d`000000

#cat launch.sh | sed -e "s:PACK=.*:PACK=$PACK:" -e "s:USERDIR=.*:USERDIR=$USERDIR:" > launch.sh2
cat launch.sh | sed -e "s:PACK=.*:PACK=$PACK:" -e 's:USERDIR=.*:USERDIR='$USERDIR':' > launch.sh2
cat task_localtest.sh | sed -e "s:export DMT_PATH.*:export DMT_PATH_EXEC=$USERDIR:" -e "s:export DMT_DATE.*:export DMT_DATE_PIVOT=$TODAY:" > task_localtest.sh2

# Replace scripts
mv task_localtest.sh2 task_localtest.sh
if [ -s launch.sh2 ]; then
	mv launch.sh2 launch.sh
else
	echo "Null file launch.sh2... not replacing"
	rm -f launch.sh2
fi
chmod +x *.sh
