#!/bin/bash
#
# This script matches files sent by TRANSMET (containing headers) with Forecast 
# ranges 
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Nov, 30  2012     #
#                                                                             #
#   VERSION :								      #
#	* v1.0 : 20121203						      # 
#		- Add WRF & filenaming convention headers		      #
#	* v1.0 : 20121130						      # 
#		- init							      #
#									      #
#   LATEST MODIFICATIONS :					  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  match_model_and_header.sh                                       	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
set -x 
rm -f match ; 
WGRIBMF=/common/GIT/mydael/scripts/bash/wgribmf.sh

for f in *.bin; do  

	workfile=$f.grib1

	$WGRIBMF $f $workfile



	#FR=`wgrib -V $workfile |grep fcst|sort -u|awk '{print $12}'|sed "s:hr::g"|awk '{printf("%04d\n",$1)}'|sort -k1|sort -u|tail -1`;
	FR=`wgrib -V $workfile |grep hr|sort -u|awk '{print $12}'|sed "s:hr::g"|awk '{printf("%04d\n",$1)}'|sort -k1|sort -u|tail -1`;

	declare -a FRA=($FR)
	arraylength=`echo ${#FRA[@]}`

	if [ $arraylength -eq 0 ]; then
		if [ -z "$FR" ]; then
			# Most probably at analysis time
			FR="0000"
		fi	
	elif [ $arraylength -eq 1 ]; then
		echo "Only one forecast range in file. Normal!"
	elif [ $arraylength -eq 2 ]; then
		echo "Accumulation + forecast range"
		FR=`echo ${FRA[1]}`
	else
		echo "Weird number of forecast ranges.. check manually in $workfile"
		exit 1
	fi

	# Get TTAAiiCCCC
	FIRST_TWO=`echo $f | cut -c1-2`
	# in case of filenaming convention (PWRF)
	if [ "$FIRST_TWO" == "T_" ]; then
		TTAAiiCCCC=`echo $f | awk 'BEGIN {FS="_"} {print $2$4"."$6}'|awk 'BEGIN {FS="."} {print $1"00"$6}'  | awk 'BEGIN {FS="00"} {print $1$3$2}'`
	else
		TTAAiiCCCC=`echo $f | cut -c3-12`; 
	fi

	case $TTAAiiCCCC in
		
		YMJ*81ALPR|YMJ*82ALPR) 
			MODEL=PALAD
			GRID=QATA0010
			;;
		YMJ*83ALPR|YMJ*84ALPR) 
			MODEL=PALAD
			GRID=LIBY0010
			;;
		YMJ*94ALPR) 
			MODEL=PALAD
			GRID=INDO0010
			;;
		YMJ*95ALPR) 
			MODEL=PALAD
			GRID=INDO0025
			;;
		YMJ*94ALVR) 
			MODEL=PALWAM
			GRID=INDO0010
			;;
		YMJ*95ALVR) 
			MODEL=PALWAM
			GRID=INDO0025
			;;
		ZGWR*HKNC) 
			MODEL=PWRF
			GRID=KNEW0062
			FR=`echo $TTAAiiCCCC| cut -c5-6`
			;;
		*)	
			echo "Unknown header... aborting"
			exit 1 ;;
	esac
			
	echo  $TTAAiiCCCC "${MODEL}_${GRID}_RECEIVED_"$FR >> match;  
	echo "" ; 
done

cat match |sort -k2 

#rm -f match

