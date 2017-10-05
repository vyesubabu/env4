#!/bin/bash
#
# This script notifies you if inotify judges it necessary
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2012     #
#                                                                             #
#   VERSION :								      #
#	* v1.1 : 20121115						      # 
#		- test hrvcloud cropping to France			      #
#	* v1.0 : 20121107						      # 
#		- init	; dictionary of variables / advisories		      #
#									      #
#   LATEST MODIFICATIONS :					  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  /common/bin/notifyme.sh $# (in argument for file passing)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#



MAIN_ARCHIPEL=/scratch/data/archipel/meteosat-highrate/
testemail=montroty.remi@gmail.com

logfile=/tmp/tutu.log
ADVISORIES_CONF=/scratch/data/archipel/varlist_vs_Advisories.conf

DATE=`date -u +"%Y%m%d%H%M%S"`
#TODAY=$MAIN_ARCHIPEL/$DATE
#cd $TODAY
file=$1
extension=`echo ${file##*.}`


# less restrictive: some extension 
#extension=`echo $f|grep -o tif.t`

#basic debug
#echo "$file $extension" | mail -s "Something Moved or Modified this file" montrotyr@mfi.fr 

#echo "1) file moved $file with ext $extension" >> $logfile

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
		
			if [ "$ADVISORY" == "METEOSAT9_SPACE_00E_HRVCLOUD" ]; then
				cd $MAIN_ARCHIPEL
				# get rid of .t , .tmp extensions
				file2process=`echo $file | sed "s:${extension}.*:$extension:"`
				echo "/common/bin/cropGeostationary.sh $MAIN_ARCHIPEL/$file2process France" >> $logfile
				/common/bin/cropGeostationary.sh $MAIN_ARCHIPEL/$file2process France &>> /tmp/exec_script.log
				#eg file=globeMhrvCloudT.archipel.20121115.1445.30.tif
			fi	
		fi
		#syntax :
		#dmtdisp GME_RUN00_COUPLING_GFFF04060000 0 20110823000000

## Get list of vars through:
# cd $MAIN_ARCHIPEL/..
#		listofvars=`ls */globe* |awk 'BEGIN {FS="."} {print $1}'|sort -u`
#
#Example of CIPS Data Advisories		
#Wed Nov 07 17:20:01 GMT 2012;imgdb;nom_ress=METEOSAT_SPACE_00W_CCG;date=20121107171500;ech=000000;qualif=0;tstamp=1352308801492
#Wed Nov 07 17:21:01 GMT 2012;imgdb;nom_ress=METEOSAT_SPACE_00W_VTS_NWC;date=20121107171500;ech=000000;qualif=0;tstamp=1352308861490
#Wed Nov 07 17:31:01 GMT 2012;imgdb;nom_ress=METEOSAT_SPACE_63E_CCMED24;date=20121107173000;ech=000000;qualif=0;tstamp=1352309461455
#Wed Nov 07 17:31:01 GMT 2012;imgdb;nom_ress=METEOSAT_SPACE_63E_CCMED24;date=20121107173000;ech=000000;qualif=0;tstamp=1352309461474
#Wed Nov 07 17:31:01 GMT 2012;imgdb;nom_ress=METEOSAT_SPACE_63E_VS_MTL;date=20121107173000;ech=000000;qualif=0;tstamp=1352309461489

		;;
	*) 
		echo "Fake extension. Fuck it : log no more" 
		exit 1;;
esac

#/common/bin/sort_archipel_files.sh $MAIN_ARCHIPEL
