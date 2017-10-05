#!/bin/bash
## 
## This script tests the RW permissions of CIPS NFS directories
#
#
# Author : Remi MONTROTY, Jan. 2010

echo "Who am I ?" $LOGNAME
echo ""
dirlist="/gridware/sge /home/sopra /common /shared"

for dir in $dirlist; do

	touch $dir/toto.$$  &> /dev/null
	if [ -f $dir/toto.$$ ]; then
		echo "$dir is writable"
	else
	   if [ "$dir" != "/common" ]; then
		echo "$dir is not writable"
		echo "Check if it belongs to user sms"
	   else
		echo "/common is not writable for safety purposes"
		echo "To edit any files it contains, please do so as user sms on cipsschedop"
	   fi
	fi
	rm -f $dir/toto.$$
	echo ""
done
