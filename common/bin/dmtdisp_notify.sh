#!/bin/bash
#
# This script is based on inotify to apply  identification of incoming files
# and sending advisories if files are known in ADVISORIES_CONF 
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Nov, 07  2012     #
#                                                                             #
#   VERSION :								      #
#	* v1.0 : 20121209						      # 
#		- init from notifyme.sh				      #
#									      #
#   LATEST INFO :					  	     	      #
#                                                                             #
#                                                                             #
#  dmtdisp_notify.sh $# (in argument for file passing)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
 
. ~/.bash_profile

## Initial declaration
file=$1
watched_dir=$2
extension=`echo ${file##*.}`
logfile=/tmp/dmtdisp_notify.log

# PATH CONFIG
testemail=montroty.remi@gmail.com
ADVISORIES_CONF=/scratch/data/varlist_vs_Advisories.conf
SENDADVISORY=/common/GIT/mydael/scripts/bash/simple_dmtdisp.sh
DATE=`date -u +"%Y%m%d%H%M%S"`

#############################################################################
#		FUNCTIONS
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
loginfo() {
 $* |tee -a $logfile
}

function grib_api_module() {
	. /etc/profile.d/modules.sh
#	module avail 
	module load taskcenter/common
	module load taskcenter/softwares/grib_api

	latest=`which grib_info`
	GRIB_API_DIR=`dirname $latest`
	GRIB_API_VERSION=`$latest -v` 

	echo "Selected grib_api version $GRIB_API_VERSION from $GRIB_API_DIR"
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function grib_advisory_sending() {
#ex ech 72H run du 25/05
#dmtdisp PGFSUS_GLOB0500_COMPLETED_0072 0 20110525000000
	export DMT_SOUS_SYSTEME=moddb
	export DMT_SERVER_HOST=10.0.15.22
	echo "$SENDADVISORY -a $ADVISORY -d $DMT_DATE_PIVOT -t $DMT_SERVER_HOST -s $DMT_SOUS_SYSTEME" >> $logfile
	$SENDADVISORY -a $ADVISORY -d $DMT_DATE_PIVOT -t $DMT_SERVER_HOST -s $DMT_SOUS_SYSTEME 
	echo "" >> $logfile
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function sat_advisory_sending() {
#dmtdisp 
	export DMT_SOUS_SYSTEME=imgdb
	export DMT_SERVER_HOST=10.0.15.22
	echo "$SENDADVISORY -a $ADVISORY -d $DMT_DATE_PIVOT -t $DMT_SERVER_HOST -s $DMT_SOUS_SYSTEME" >> $logfile
	$SENDADVISORY -a $ADVISORY -d $DMT_DATE_PIVOT -t $DMT_SERVER_HOST -s $DMT_SOUS_SYSTEME 
	echo "" >> $logfile
		
}
#~~~~
function extension_processing() {

	case $extension in 
		tif) 
			variable=${file%%.*}
			datevalid=`echo $file|awk 'BEGIN {FS="."} {print $3}'`
			hourvalid=`echo $file|awk 'BEGIN {FS="."} {print $4}'`

			DMT_DATE_PIVOT=${datevalid}${hourvalid}"00"
	
			echo "$DATE | file $file moved with ext $extension. DMT_DATE_PIVOT=$DMT_DATE_PIVOT" >> $logfile
			ADVISORY=`grep $variable $ADVISORIES_CONF | awk '{print $2}'`
		
			if [ ! -z "$ADVISORY" ]; then
				echo "" >> $logfile
				echo "Known advisory for $variable is $ADVISORY" >> $logfile

				echo "dmtdisp $ADVISORY 0 $DMT_DATE_PIVOT" >> $logfile
			
				#~ 
				sat_advisory_sending

			fi
			;;
		bin) 
			#basic debug
			echo "$file $extension in $watched_dir" | mail -s "sort_models.sh moved this file into $watched_dir"  $testemail
			
			set -x

			echo "WATCHED_DIR=$watched_dir" >> $logfile
			
			# do NOT comment out the following!
			cd $watched_dir 
			
			echo "### LS of dir $PWD #####" >> $logfile
			ls >> $logfile 

			echo "$DATE | file $file moved||created in $watched_dir with ext $extension" >> $logfile
			#~~ select grib_api to use
			grib_api_module 
			
			echo "##### FILE IS #####" >> $logfile
			ls -lrt $watched_dir/$file >> $logfile

			isGRIB=`$GRIB_API_DIR/grib_dump -O $file|grep identifier|awk '{print $4}'|sort -u |tee -a $logfile` 

			if [ "$isGRIB" == "GRIB" ]; then
				GRIBVERSION=`$GRIB_API_DIR/grib_dump -O $file|grep editionNumber|awk '{print $4}'|sort -u`
				TTAAiiCCCC=`echo $file |cut -c1-10 `
				echo $TTAAiiCCCC >> $logfile
				DMT_DATE_PIVOT=`$GRIB_API_DIR/grib_ls -p date,time $file |grep -v "[a-Z]"|sort -u |grep -v "^$" |awk '{ printf("%8d%02d0000\n",$1,$2) }' `

				ADVISORY=`grep $TTAAiiCCCC $ADVISORIES_CONF | awk '{print $2}' | tee -a $logfile`
				if [ ! -z "$ADVISORY" ]; then
					echo ""
					echo "Known advisory for $TTAAiiCCCC is $ADVISORY" >> $logfile
				
					#~ 
					grib_advisory_sending

				fi

			else
				echo "We have used grib_api $GRIB_API_VERSION from $GRIB_API_DIR to diagnose $file in $watched_dir " >> $logfile
				echo "Not a GRIB file " >> $logfile

			fi

			;;
		*) 
			echo "Fake extension. Fuck it : log no more" 
			exit 1;;
	esac
}

######################### END FUNCTION #######################################


######################### START MAIN #######################################

echo "$0 called at $DATE" | mail -s "$watched_dir being scanned for notifications" montroty.remi@gmail.com
#~
extension_processing

