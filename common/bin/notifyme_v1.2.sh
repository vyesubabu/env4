#!/bin/bash
#
# This script is based on inotify to apply selective processing to files
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Nov, 07  2012     #
#                                                                             #
#   VERSION :								      #
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

## Initial declaration
file=$1
extension=`echo ${file##*.}`
logfile=/tmp/incrontab.log
MAIN_ARCHIPEL=/scratch/data/archipel/meteosat-highrate/

# PATH CONFIG
testemail=montroty.remi@gmail.com
ADVISORIES_CONF=/scratch/data/archipel/varlist_vs_Advisories.conf
DATE=`date -u +"%Y%m%d%H%M%S"`

#############################################################################
#		FUNCTIONS

#~~~~
function cropGeo() {

	DOMAIN_TO_CROP=$1
	echo "/common/bin/cropGeostationary.sh $MAIN_ARCHIPEL/$file2process $DOMAIN_TO_CROP" >> $logfile
	/common/bin/cropGeostationary.sh $MAIN_ARCHIPEL/$file2process $DOMAIN_TO_CROP &>> /tmp/cropGeo.log

}

#~~~~
function advisory_processing() {

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
			echo "$DATE | file $file moved with ext $extension" >> $logfile
			variable=${file%%.*}
			datevalid=`echo $file|awk 'BEGIN {FS="."} {print $3}'`
			hourvalid=`echo $file|awk 'BEGIN {FS="."} {print $4}'`
			
			ADVISORY=`grep $variable $ADVISORIES_CONF | awk '{print $2}'`
		
			if [ ! -z "$ADVISORY" ]; then
				echo "Known advisory for $variable is $ADVISORY" >> $logfile
				echo "dmtdisp $ADVISORY 0 $datevalid${hourvalid}00" >> $logfile
			
				#~ 
				advisory_processing

			fi
			#syntax :
			#dmtdisp GME_RUN00_COUPLING_GFFF04060000 0 20110823000000
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

