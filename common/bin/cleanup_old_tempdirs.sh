#!/bin/bash
. /common/bin/cips_bash_functions.sh

dir=$1

### Specify that Ndays is old enough...
NDAYS_OLD=3

if [ -z "$dir" ]; then
   echo "Use is : cleanup_old_dirs /path/to/parentfolder"
fi

ndays_old_subsdirs_of_dir $dir $NDAYS_OLD
list=`ndays_old_subsdirs_of_dir $dir $NDAYS_OLD`


echo ""
#echo "Delete ALL? [y/n]"
#read answer
answer="YESSIR"
if [ "$answer" == "y" ]; then
	echo "We don't trust you. Specify each dir anyway! Or redo with YESSIR to automatically remove all!"
	for d in $list; do
		rm -rfi $d
	done
elif  [ "$answer" == "YESSIR" ]; then
	for d in $list; do
		rm -rf $d
	done
fi
