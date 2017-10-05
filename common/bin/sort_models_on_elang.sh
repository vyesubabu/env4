#!/bin/bash
#
# This script automatically sorts models according to headers + $WGRIB content
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Nov, 28  2012     #
#                                                                             #
#   VERSION :								      #
#	* v3.2.0-rev2: 20140909					      # 
#		- Add: grib_api 1.12.1 update
#	* v3.2.0-rev1: 20140904					      # 
#		- Add: ECMC model
#	* v3.2b2-rev4 : 20140828					      # 
#		- Mod: use /home/models on BMKG HPC (models@CSDJAN)
#		- Mod: getdiskuse now fetches from $5 of df -hv
#	* v3.2b2-rev3 : 20140528					      # 
#		- Mod: getdiskuse now fetches from $4 of df -hv
#		- Mod: add ECMA & gridstring values for ECMWF 0.125°
#		  and ECWAM 0.25°
#	* v3.2b2-rev2 : 20140519					      # 
#		- Mod: gridstring from /common/bin/
#		- Add: STORAGEFS to store in /nas/models
#	* v3.2b2-rev1 : 20140516					      # 
#		- Add: ECMWF string for CEP 0.5°
#		- Mod: change to /home/models for MODDIR + GIT dir
#		- Mod: change /common/bin/wgrib
#	* v1.2.6 : 20140320						      # 
#		- change to /home/models for MODDIR + GIT dir
#	* v1.2.5 : 20130717						      # 
#		- change to /nas/models
#	* v1.2.4 : 20130715						      # 
#		- further fix: get FR after mastergrb2f string!
#	* v1.2.3 : 20130714						      # 
#		- further fix: get FR after pgrb2f string!
#
#	* v1.2.2 : 20130517						      # 
#		- further fix:  handle single header from GFS routing...(!)
#		- change extension to grb2
#	* v1.2.1 : 20130516						      # 
#		- dirty fix:  GFSUS GLOB0500 GRIB2 support...
#			needs a proper fix with grib_api
#		- bugged removed again: DOMAIN=modstring not DOMAINFR
#	* v1.2 : 20121218						      # 
#		- added:  FORECAST_RANGE support
#		- remove: select_rundate function unused
#		- quickmod: add * to gridstrings to account for forecast ranges
#		- bugfix: export LANG for enabling regex through crontab!
#		- bugfix: in case 2 RUNDATES are found, we force the 201* one
#			(to be changed in December 2019 :P)
#	* v1.1 : 20121209						      # 
#		- Rewrite for a clean separation of sorting & notification    #
# 		through dmtdisp						      #
#		- add: LOCK file					      #
#	* v1.0 : 20121128						      # 
#		- Init							      #
#									      #
#   LATEST MODIFICATIONS :					  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function select_modeltype() {
	file=$1
	VAG=`echo $file|grep ALVR`
	ALD=`echo $file|grep ALPR`
	WRF=`echo $file|grep ZGWR`
	GFS=`echo $file|grep HGFS`
	ECMWF=`echo $file|grep ECMA`
	ECMC=`echo $file|grep ECMC`
	GFSRAW=`echo $file|grep mastergrb2f`

	if [ ! -z "$VAG" ]; then
		MODELTYPE="PVAG"
	elif [ ! -z "$ALD" ]; then
		MODELTYPE="ALADIN"
	elif [ ! -z "$WRF" ]; then
		MODELTYPE="WRF"
	elif [ ! -z "$GFS" ]; then
		MODELTYPE="GFSUS"
	elif [ ! -z "$GFSRAW" ]; then
		MODELTYPE="GFSUS"
	elif [ ! -z "$ECMWF" ]; then
		MODELTYPE="ECMWF"
	elif [ ! -z "$ECMC" ]; then
		MODELTYPE="ECMWF"
	else
		MODELTYPE="UNKNOWN"
	fi
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function isnumber(){ 
	printf '%f' "$1" &>/dev/null && echo "yes, it's a number" || echo "no, not a number"; 
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function getdiskuse() {
	PercentageDiskUse=`df -hv .|tail -1|awk '{print $5}'|sed "s:%::"`
	echo "Disk use= $PercentageDiskUse . Threshold at $MAX_DISK_USE"
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function grib_api_rundate() {
	file=$1
	#module load grib_api/1.10.0
	module load grib_api/1.12.1

	# needed for [a-Z] regexp!
	export LANG=en_US.UTF-8

	# use printf to preserve HHMM format for the hour
	#RUNDATE=`grib_ls -p date,time $file | sed -e "/.*[a-Z].*/d" -e "/^$/d" | sort -u | awk '{ printf("%d%04d\n", $1,$2) }'`
	RUNDATE=`grib_ls -p date,time $file | grep -v "[a-Z]" | grep "^201*" | sort -u | grep -v "^$" | awk '{ printf("%d%04d\n", $1,$2) }'`
}

#######################################################################
#### 				MAIN 
#set -x
set +x 

NDAYS=5
MAX_DISK_USE=50

# Start with loading modules
. /etc/profile.d/modules.sh
export MODULEPATH=$MODULEPATH:/cm/shared/modulefiles
module load taskcenter/common
#GRIDSTRING=`which gridstring.sh`
#GRIDSTRING=/common/GIT/mydael/scripts/bash/gridstring.sh
GRIDSTRING=/common/bin/gridstring.sh

MODDIR=$1
if [ -z "$MODDIR" ]; then
	MODDIR=/home/models
fi
#STORAGEFS=/nas/models
STORAGEFS=/home/models

scriptname=`basename $0`
LOCKNAME=$scriptname.LOCK
LOCK=/tmp/$LOCKNAME

UNIMPORTANT_MODELS="ALADIN_NEWCALEDONIA ALADIN_LIBYA PVAG_LIBYA PVAG_QATAR GFSUS_GLOB"
NDAYS_FOR_UNIMPORTANT=1


# Avoid deadlocks where a LOCK file is never destroyed 
# by forcing deletion every 60 min
find_and_deleteOldLocks=`find /tmp/* -type f -mmin +15 -name "$LOCKNAME" -exec rm -f '{}' \;`

if [ -f $LOCK ]; then 
	echo "Already processing. exit gracefully"
	exit 0
else
	touch $LOCK
fi

## check binaries 
WGRIB=`which wgrib`
if [ -z "$WGRIB" ]; then
	WGRIB=/common/bin/wgrib
	if [ ! -f $WGRIB ]; then
		echo "No wgrib found in $WGRIB. Aborting"
		exit 1
	fi	
fi
if [ ! -f $GRIDSTRING ] ; then
	echo "Could not find gridstring.sh in $GRIDSTRING"
	echo "Aborting"
	exit 1
fi
YYYYMMDD=`date -u +%Y%m%d`
DD=`date -u +%d`
YYYYMM=`date -u +%Y%m`


cd $MODDIR
FL=`ls *.bin`
GRIBFL=`ls *.grb`
GFSRAW=`ls *mastergrb2f*.grb2`
FL="$FL $GRIBFL $GFSRAW"


for f in $FL ;do
	
	select_modeltype $f

	#~~
	#select_rundate
	grib_api_rundate $f
	
	modstring=`$GRIDSTRING $f`
	RESOLUTIONFR=${modstring##*_GRID}
	FR=${modstring##*_FR_}
	if [ "$MODELTYPE" == "GFSUS" ]; then
		DOMAIN="GLOB"
		RESOLUTION="0500"
	else
		DOMAIN=${modstring%%_GRID*}
		RESOLUTION=${RESOLUTIONFR%%_FR*}
	fi
	
	case $DOMAIN in
	85-0-*_LAT-10.000000-30.000000_LON156.000000174.000000*) 
		MODEL="${MODELTYPE}_NEWCALEDONIA" ;;
	85-0-*_LAT15.000000-15.000000_LON95.000000150.000000*)
		MODEL="${MODELTYPE}_INDONESIA" ;;
	85-0-*_LAT31.00000023.000000_LON47.00000060.000000*)
		MODEL="${MODELTYPE}_QATAR" ;;
	85-0-*_LAT34.00000018.000000_LON8.00000028.000000*)
		MODEL="${MODELTYPE}_LIBYA" ;;
	14-0-125_LAT-15.00000016.000000_LON23.00000053.000000*)
		MODEL="${MODELTYPE}_KENYA" ;;
	98-0-110_LAT40.000000-25.000000_LON70.000000170.000000*)
		MODEL="ECWAM_INDONESIA" ;;
	98-0-144_LAT40.000000-25.000000_LON70.000000170.000000*)
		MODEL="${MODELTYPE}_INDONESIA" ;;
	*)	
		MODEL=${MODELTYPE}_$DOMAIN ;;
	esac
	
	if [ ! -z "$STORAGEFS" ]; then
		STORAGE=$STORAGEFS/$MODEL/GRID_$RESOLUTION
	else
		echo "Please define which FileSystem to store in via STORAGEFS. Empty.. abort"
		exit 1
	fi
	STORAGEDIR=$STORAGE/$RUNDATE


	# figure out latest run dir BEFORE you move the file inside!
	# else incrontab does not see the move ..
	
	# create TODAY's dir if need be
	[ -d $STORAGEDIR ] || mkdir -p $STORAGEDIR
	cd $STORAGE

	# assign latest to latest (NOT to STORAGEDIR, as we may be receiving old files)
	latest=`ls -1d 201*|tail -1`
	rm -f latest
	ln -sf $latest latest

	# move file to its TODAY's dir
	# Get TTAAiiCCCC
	cd $MODDIR
	
	# in case of filenaming convention (PWRF), figure out TTAAiiCCCC to prefix file
	FIRST_TWO=`echo $f | cut -c1-2`
	if [ "$FIRST_TWO" == "T_" ]; then
		# introduce ## as a field separator & print forecast range as ii 
		TTAAiiCCCC=`echo $f | awk 'BEGIN {FS="_"} {print $2"##"$4"."$6}' |awk 'BEGIN {FS="."} {print $1"##"$6}'| awk 'BEGIN {FS="[0-9]*##"} {print $1$3$2}'`
		FREEFORMAT=`echo ${f##*_}`
		newfile=${TTAAiiCCCC}_${FREEFORMAT}

	elif [ "$FIRST_TWO" == "A_" ]; then
		# 
		TTAAiiCCCC=`echo $f | cut -c3-12`

		if [ "$TTAAiiCCCC" == "HGFS05KWBC" ]; then
			RUNDATE=`echo $f |cut -c27-38`
			#FR=`echo $f |cut -c62- | sed "s:.bin::g"`
			FR=`echo ${f##*mastergrb2f}|sed "s:\..*::g"`
			extension="grb2"
		else
			extension="grb"
		fi 
		FREEFORMAT="${MODEL}.$RUNDATE.$FR.$extension"
		newfile=${TTAAiiCCCC}_${FREEFORMAT}
	else
		newfile=$f

	fi	
	
	# perform the move
	mv $f $STORAGEDIR/$newfile
	echo "moved $f to $STORAGEDIR/$newfile"

done


## Pre-emptive cleanup
cd $MODDIR

#~~
getdiskuse

if [ $PercentageDiskUse -ge $MAX_DISK_USE ]; then 
	
	List_LastWeekFiles=`find . -type f -mtime $NDAYS`
	if [ ! -z "$List_LastWeekFiles" ]; then
		List_and_Delete_LastWeekFiles=`find . -type f -mtime $NDAYS -exec rm -f '{}' \;`
		echo "We've deleted files older than $NDAYS days"
		echo "List=$List_LastWeekFiles"

		#~~
		getdiskuse
	fi

	# Further clean on UNIMPORTANT_MODELS
	if [ $PercentageDiskUse -ge $MAX_DISK_USE ]; then 
		for mod in $UNIMPORTANT_MODELS; do

			cd $MODDIR/$mod
			echo "Further cleanup on $MODDIR/$mod"
			List_and_Delete=`find . -type f -mtime $NDAYS_FOR_UNIMPORTANT -exec rm -f '{}' \;`

		done
	fi

	#~~
	getdiskuse

	
else
	set +x
	#List_LastWeekFiles=`find . -type f -mtime $NDAYS `
	FL=`find . -type f -mtime $NDAYS `

	if [ ! -z "$FL" ];then
	#	echo $FL
		NFL=`echo $FL|wc -w`
		echo "$NFL were files older than $NDAYS days"
	else
		echo "No files older than $NDAYS days"
	fi
fi

# Cleanup
rm -f $LOCK
