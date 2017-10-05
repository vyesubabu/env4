#!/bin/bash
#
# This script performs cleaning of the HOLDSAVE directory when disk use threshold
# is too high and removes files/directories older than $NDAYS 
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 03  2012     #
#                                                                             #
#   VERSION :								      #
#	* v1.2 : 20120227						      # 
#		-	Added return to $HOLDSAVE
#	* v1.1 : 20120214						      # 
#		-	Added remove_wrfout function			      #
#	* v1.0								      # 
#		-	Version using date_substract.sh			      #
#									      #
#   LATEST MODIFICATIONS :					  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  ./clean_holdsave.sh 	                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

HOLDSAVE=/nfs/holdspace
export COMMON_HOME=/share/common

## Maximum age of files to be retained
NDAYS=10

## Use percentage of harddrive before cleaning
MAX_PERCENTAGE_HDD=50

TODAY=`date -u +%Y%m%d%H%M%S`

. /share/common/bin/cips_bash_functions.sh 

cd $HOLDSAVE
set +x 
space_used=`du -sh . |sed "s:G::g" | awk '{print $1}'`
#space_total=`/bin/df -h . |tail -1 |awk '{print $2}'|sed "s:G::g"` 

## on 2 lines => $1 = total
space_total=`/bin/df -h . |tail -1 |awk '{print $1}'|sed "s:G::g"` 


PERCENTAGE_USED=`echo "$space_used $space_total" |awk '{printf("%d\n",$1/$2*100)}'`
let PERCENTAGE_LEFT=100-PERCENTAGE_USED
set +x
#echo "##" $PERCENTAGE_USED "##" $PERCENTAGE_LEFT "##"

## Define DIRLIST to clean
set +x
DIRLIST=`ls -1d $HOLDSAVE/COSMO/*/`
DIRLIST="$DIRLIST `ls -1d $HOLDSAVE/HRM/*/`"
DIRLIST="$DIRLIST `ls -1d $HOLDSAVE/WRF/*/`"
DIRLIST2CLEAN=`echo $DIRLIST |sed 's: :\n:g'`
echo "DIRLIST=$DIRLIST"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                       FUNCTIONS
#
## F1
remove_wrfout() {

  dir=$1
  NHOURS=$2

  if [ -z "$*" ]; then
        echo "usage: remove_wrfout DIR NHOURS"
  elif [ -z "$NHOURS" ]; then
        echo "Using default : NHOURS=6"
        NHOURS=6
  fi
  echo "Removing wrfout files from $dir, older than $NHOURS h"

  let NMIN=60*NHOURS
  cd $dir
  find . -name 'wrfout*' -mmin +$NMIN -exec rm -f {} \;
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#



if [ $PERCENTAGE_USED -gt $MAX_PERCENTAGE_HDD ]; then
	echo "We are using too much disk space :  $PERCENTAGE_USED % used... Threshold at $MAX_PERCENTAGE_HDD %!"

	## FIRST PASS : Eliminate all the coupling files directories
	echo "Removing Coupling files first & wrfout files if any"
	for dir in $DIRLIST; do
		find $dir -mtime +$NDAYS -type d  | grep PGFSUS | xargs rm -rf 
		find $dir -mtime +$NDAYS -type d  | grep "/in" | xargs rm -fr 

		#~~
		remove_wrfout $dir 
		
		## Come back to main dir 
		cd $HOLDSAVE 
	done

	space_used=`du -sh . |sed "s:G::g" | awk '{print $1}'`
	PERCENTAGE_USED=`echo "$space_used $space_total" |awk '{printf("%d\n",$1/$2*100)}'`

	## if cleaning was enough, exit ; else continue by removing the full directories
	if [ $PERCENTAGE_USED -le $MAX_PERCENTAGE_HDD ]; then
		echo "We're back to nominal conditions :  $PERCENTAGE_USED % used... Threshold at $MAX_PERCENTAGE_HDD %!"
		exit 0
	else
		echo "Still missing too much space : $PERCENTAGE_USED % used... Threshold at $MAX_PERCENTAGE_HDD %!"
		echo "Cleaning full directories!"

		for dir in $DIRLIST; do
			#OLD_SUBDIRS=`ndays_old_subsdirs_of_dir $dir $NDAYS`
			OLD_SUBDIRS=`find $dir -maxdepth 1 -type d`
			let THRESHOLD=NDAYS*86400

			for d in $OLD_SUBDIRS; do
				lastdir3=`echo ${d##*/} | cut -c1-3`
				lastdir=`echo ${d##*/}`

				## delete only subdirs that start with 201x 
				if [ "${lastdir3}" == "201" ]  ; then
					timeDiff=`$COMMON_HOME/bin/date_substract.sh $lastdir $TODAY`
					isTooOld=`echo  $timeDiff |awk '{if ( $1 > '$THRESHOLD' ) {print "yes" }}'`
					#isTooOld=`echo  $lastdir $TODAY |awk '{if ( $2-$1 > '$THRESHOLD' ) {print "yes" }}'`
					if [ "$isTooOld" == "yes" ]; then
						echo "rm -rf $d"
						rm -rf $d
					fi
				fi
				
			done
		done
	fi
	space_used=`du -sh . |sed "s:G::g" | awk '{print $1}'`
	PERCENTAGE_USED=`echo "$space_used $space_total" |awk '{printf("%d\n",$1/$2*100)}'`
	echo "Disk space is now:  $PERCENTAGE_USED % used... Threshold at $MAX_PERCENTAGE_HDD %!"
else
	echo "We are not using too much disk space:  $PERCENTAGE_USED % used... Threshold at $MAX_PERCENTAGE_HDD %!"
	echo ""
	echo "NO REQUIRED CLEANING FOR $DIRLIST2CLEAN"
	exit 0
fi
