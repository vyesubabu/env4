
#!/bin/bash
#
# This script compares the evolution of the missing files from WRF real time
# with what is expected, so as to know what dates need to be rerun
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   FEb, 10  2015     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0: 20150210						      # 
#		-Init							      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  $0 $date_start $date_end                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#REV3d3_20150128120000_024_*

set -e

DAY_START=$1
DAY_END=$2

function usage()  {
echo "$0 DATEBEGIN DATEEND"
exit 1
}


. /common/bin/cips_bash_functions.sh
dpp="date -u"
MODEL_LIST="REV3d12 REV3d3"

if [ -z "$DAY_START" ]; then
	usage
DAY_START=20150120
fi
if [ -z "$DAY_END" ]; then
	usage
DAY_END=20150210
fi


DATELIST=`/common/bin/gen_datelist.bash $DAY_START $DAY_END 12 hours`
FRLIST="00 12 24"


for date in $DATELIST; do 
   for mdl in $MODEL_LIST; do 

	case $mdl in 
		REV3d12) DOMAINLIST="d01 d02";;
		REV3d3) DOMAINLIST="d01";;
		*) echo  "DOMAINLIST not defined for model $mdl ";  exit 1;;
	esac

	DIR=/Assim/SAVE/$mdl/WRFV35

	count=0
	missingdom=""

	for FR in $FRLIST; do 
  	  for domain in $DOMAINLIST; do 

		DATE="${date}0000"
		DATE="${date}"

		#echo $DATE
		prefix="${mdl}_${DATE}_0${FR}_wrfout_${domain}_"
       	 	FMTDATE=`date14_to_fmt $DATE`
        	DATEPLUS=`$dpp --date="$FMTDATE GMT +$FR hours" +"%Y-%m-%d_%H:%M:%S"`

		## define filename we're looking for
		#REV3d3_20150209000000_024_wrfout_d01_2015-02-10_00:00:00.bz2
		file=$DIR/"${prefix}${DATEPLUS}.bz2"
		if [ -f $file ] && [ -s $file ]; then
#			echo "file $file exists and not null"
			continue
		else
#			echo "missing $file in $DATE"
			let count=count+1
			missingdom="$missingdom $domain_$FR"
		fi
	  done
	done ##end FRLoo
	if [ $count -ne 0 ]; then
		echo "$count missing files for $DATE for $mdl"
#		echo "files missing for domains $missingdom"
		echo ""
	fi
  done
done



