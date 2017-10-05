
#!/bin/bash
#
# This script does stuff
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0: 20150302						      # 
#		-use GFS_ARCHIVE_DIR							      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#



GFS_ARCHIVE_DIR=/nas1/DATA/models/GFSUS_GLOB/GRID_0500



cd $GFS_ARCHIVE_DIR
echo "Trimming above 140h"
#find . -name "HGFS*.1[456789][0-9].grb2" | xargs rm -f 

#FILESNEEDED=36 ## up to 132
#FILESNEEDED=13 ## up to 36


FRNEEDED=`seq 0 3 36`
FILESNEEDED=`echo $FRNEEDED |wc -w`

function list_frneeded() {



FRFILES=""
for FR in $FRNEEDED ; do 

	set +x
	FR2D=`echo $FR |awk '{printf("%02g\n", $1) }'`
	
	POSSIBLE_FILE1=`ls HGFS*.$FR.grb 2>/dev/null `
	POSSIBLE_FILE2=`ls HGFS*.$FR2D.grb2  2>/dev/null`
	if [ -f "$POSSIBLE_FILE1" ]  || [ -f "$POSSIBLE_FILE2" ]; then
#		echo "found a file for $FR on $dir"
		FRFILES="$FRFILES HGFS.$FR.grb"
	fi
	set +x
done
#set -x 
NFILES_FOUND=`echo $FRFILES | wc -w `
echo $NFILES_FOUND
} 

count=0
#for dir in `ls -1d 201*`; do  
for dir in `ls -1d 2015*`; do  
	cd $dir; 

#	NFILES=`ls *.grb*|wc -l`
	NFILES=`list_frneeded`
#set -x 
	if [ $NFILES -ge $FILESNEEDED ] ; then
		let count=count+1
		echo "continuous sequence=$count on $dir"

	else
		echo ""
		echo "max continuous sequence=$count from $datestart to $dir"
		echo ""
		echo "resetting to 0 on date $dir"
		echo "NFILES in $dir " $NFILES
		count=0
		datestart=$dir
	fi
	cd ..;  
done


