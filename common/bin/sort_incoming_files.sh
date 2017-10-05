#!/bin/bash
#
# This script is based on inotify to apply selective processing to files
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Dec, 09  2012     #
#                                                                             #
#   VERSION :								      #
#	* v1.0 : 20121209						      # 
#		- Init through copy of v1.4 of notifyme.sh		      #
#									      #
#   LATEST INFO :					  	      #
#         
#                                                                             #
#  sort_incoming_files.sh $# (in argument for file passing)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
 
. ~/.bash_profile

## Initial declaration
file=$1
watched_dir=$2
extension=`echo ${file##*.}`
logfile=/tmp/sort_incoming_files.log
SORT_ARCHIPEL=/common/GIT/mydael/scripts/bash/sort_archipel_files.sh
SORT_MODELS=/common/GIT/mydael/scripts/bash/sort_models.sh

# PATH CONFIG
testemail=montroty.remi@gmail.com
DATE=`date -u +"%Y%m%d%H%M%S"`

#############################################################################
#		FUNCTIONS
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
loginfo() {
 $* |tee -a $logfile
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function sort_tif_files() {

	# Find file to process
	$SORT_ARCHIPEL $watched_dir 2>&1 >> /tmp/sortarc.log
	
	# if we want to sort everything:
	# $SORT_ARCHIPEL
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function sort_bin_files() {

	# Find file to process
	$SORT_MODELS $watched_dir 2>&1 >> /tmp/sortmod.log
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function extension_processing() {

	case $extension in 
		tif) 
			echo "$DATE | Satellite file $file moved with ext $extension in $watched_dir. " >> $logfile
		
			#~~
			sort_tif_files
		
			;;
		bin) 
			echo "$DATE | Model file $file moved with ext $extension in $watched_dir. " >> $logfile
		
			#~~
			sort_bin_files
			;;
		*) 
			echo "Fake extension. Fuck it : log no more" 
			exit 1;;
	esac
}

######################### END FUNCTION #######################################


######################### START MAIN #######################################

#~
extension_processing

