#!/bin/bash
#
# This script is based on inotify to apply selective processing to files
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Nov, 07  2012     #
#                                                                             #
#   VERSION :								      #
#	* v1.4 : 20121206						      # 
#		- Add: change from Advisory sending or processing	      #
# 	This is a major conceptual change: we do not launch processing directly
#		at this point. It is done by the task center...
#	* v1.3 : 20121130						      # 
#		- Add: ALADIN-Indonesia specific processing		      #
#	* v1.2 : 20121121						      # 
#		- Rewrite with functions for selective processing of channels #
#	* v1.1 : 20121115						      # 
#		- test hrvcloud cropping to France			      #
#	* v1.0 : 20121107						      # 
#		- init	; dictionary of variables / advisories		      #
#									      #
#   LATEST INFO :					  	      #
#         
## Get list of vars through:
# cd $MAIN_ARCHIPEL/..
#		listofvars=`ls */globe* |awk 'BEGIN {FS="."} {print $1}'|sort -u`
#
#Example of CIPS Data Advisories		
#Wed Nov 07 17:20:01 GMT 2012;imgdb;nom_ress=METEOSAT_SPACE_00W_CCG;date=20121107171500;ech=000000;qualif=0;tstamp=1352308801492
#Wed Nov 07 17:21:01 GMT 2012;imgdb;nom_ress=METEOSAT_SPACE_00W_VTS_NWC;date=20121107171500;ech=000000;qualif=0;tstamp=1352308861490
#Wed Nov 07 17:31:01 GMT 2012;imgdb;nom_ress=METEOSAT_SPACE_63E_VS_MTL;date=20121107173000;ech=000000;qualif=0;tstamp=1352309461489
#   Example:                                                                  #
#                                                                             #
#  /common/bin/notifyme.sh $# (in argument for file passing)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
 
. ~/.bash_profile

## Initial declaration
file=$1
watched_dir=$2
extension=`echo ${file##*.}`
logfile=/tmp/incrontab.log
MAIN_ARCHIPEL=/scratch/data/archipel/meteosat-highrate/
MAIN_MODELS=/scratch/data/models
SORT_ARCHIPEL=/common/GIT/mydael/scripts/bash/sort_archipel_files.sh

# PATH CONFIG
testemail=montroty.remi@gmail.com
ADVISORIES_CONF=/scratch/data/varlist_vs_Advisories.conf
SENDADVISORY=/common/GIT/mydael/scripts/bash/simple_dmtdisp.sh
CROPGEO=/common/GIT/mydael/scripts/bash/cropGeostationary.sh
DATE=`date -u +"%Y%m%d%H%M%S"`

#############################################################################
#		FUNCTIONS
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
loginfo() {
 $* |tee -a $logfile
}

#~~ select latest grib_api 
function selectLatestGribApi() {

	GRIBINFOS=`locate grib_info|grep bin`
	for g in $GRIBINFOS; do 
		version=`$g -v`; 
		echo $g $version >> gribinfos.list; 
	done
	latest=`cat gribinfos.list |sort -k 1|tail -1|awk '{print $1}'`

	GRIB_API_DIR=`dirname $latest`
	GRIB_API_VERSION=`$latest -v` 

	echo "Selected grib_api version $GRIB_API_VERSION from $GRIB_API_DIR"

	# cleanup
	rm -f gribinfos.list
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

#~~~~
function cropGeo() {

	DOMAIN_TO_CROP=$1
	echo "$CROPGEO $MAIN_ARCHIPEL/$file2process $DOMAIN_TO_CROP" >> $logfile
	$CROPGEO $MAIN_ARCHIPEL/$file2process $DOMAIN_TO_CROP &>> /tmp/cropGeo.log
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
function sat_advisory_processing() {

	# Find file to process
	cd $MAIN_ARCHIPEL
	# get rid of .t , .tmp extensions
	file2process=`echo $file | sed "s:${extension}.*:$extension:"`

	case $ADVISORY in

		"METEOSAT9_SPACE_00E_HRVCLOUD") 
				cropGeo France
				cropGeo DjiboutiLarge
			;;
		"METEOSAT9_SPACE_00E_HRVFOG") 
				cropGeo France
			;;
		"METEOSAT9_SPACE_00E_DUST") 
				cropGeo DjiboutiLarge
			;;
		*)	
			echo "Unknown processing for advisory $ADVISORY"
			;;
	esac
		
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
				echo "from exec $$ ; Known advisory for $variable is $ADVISORY" >> $logfile

			# you cannot sort before you know it's a known advisory
			# else you can sort based on unknown files & no advisory is sent
				echo `date -u`" : from exec $$; Calling $SORT_ARCHIPEL" >> $logfile
				$SORT_ARCHIPEL

				echo "from exec $$; here are the sorted files" >> $logfile
				cat /tmp/sortdir.$$ >> $logfile
				rm -f /tmp/sortdir.$$

				echo "from exec $$ ; dmtdisp $ADVISORY 0 $DMT_DATE_PIVOT" >> $logfile
			
				#~ 
				#sat_advisory_processing
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
			#file=A_YMJZ94ALPR291200_C_MFIA_------291200--.bin

			#~~ select grib_api to use
			#selectLatestGribApi (obsolete)
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
				#echo "File $file has advisory $ADVISORY " >> $logfile
			
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

#~
extension_processing

