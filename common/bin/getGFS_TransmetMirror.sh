#!/bin/bash
#
# This script gets data from the TRANSMET Mirror as a backup for GFS
# if GFS not in Data Center
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Sep, 01  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.2: 20140919						      # 
#		- Add: function sizeOf
#	* v1.0.1: 20140904						      # 
#		- Add: use GFSTMP for download (not scanned)
#	* v1.0.0: 20140903						      # 
#		- Add: function to get from TRANSMET mirror		      #
#		- Add: 6hourly switch from 72
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


#http://172.19.22.69/mirror/gfs/gfs.2014090212/master/gfs.t12z.mastergrb2f48

function use() {
echo "$0 DOMAIN YYYYMMDDHH opt:SINGLEFR"
echo "eg $0 MIRROR 2014090300"
echo
echo "Options for DOMAIN: MIRROR, WORLD, INDO"
}
sizeOf() {
	file=$1
	size=`ls -lrt $file|awk '{print $5}'`
	echo $size
}


DOMAIN=$1
RUNDATE=$2
RANGEMAX=132
RANGE_6HOURLY=72

## Optional 
SINGLE_FORECAST_RANGE=$3

if [ -z $1 ] ; then
	use
	exit 1
fi


if [ -z "$LOGFILE" ]; then
	echo "Pb with LOGFILE = $LOGFILE"
#	exit 999
else
	echo "Getting GFS from nomads.noaa.gov " >> $LOGFILE
fi

DAY=`echo $RUNDATE | cut -c1-8`
RUN=`echo $RUNDATE | cut -c9-10`
echo "Running on $DAY for RUN $RUN" | tee $LOGFILE

## 10 digits
#TODAY=$DAY$RUN
TODAY=$RUNDATE
## 14 digits
TODAYHOLD=$RUNDATE

GFSHOLD=/home/models/TMP
GFSTMP=/home/models/TMP
GFSDIR=/home/models

mkdir -p $GFSDIR
mkdir -p $GFSHOLD


case $DOMAIN in 
	MIRROR) 
	get_model="Lget_mirror"
	;;
	WORLD) 
	get_model="Lget_full"
	leftlon=-180
	rightlon=180
	toplat=90
	bottomlat=-90
	;;
	INDO) 
	get_model="Lget_indo"
	leftlon=70
	rightlon=150
	toplat=25
	bottomlat=-25
	;;
	*)
	echo "What the hell"
	exit 1
esac


## Define forecast ranges to be fetched
set -x
if [ -z "$SINGLE_FORECAST_RANGE" ] ; then
	## we do not run in single forecast range extraction mode
	if [ $RANGEMAX -gt $RANGE_6HOURLY ]; then	
		FR_FETCHING_LIST1=`seq 0 3 $RANGE_6HOURLY`
		let RANGESTART2=RANGE_6HOURLY+6
		FR_FETCHING_LIST2=`seq $RANGESTART2 6 $RANGEMAX`
		FR_FETCHING_LIST="$FR_FETCHING_LIST1 $FR_FETCHING_LIST2"
	else
		FR_FETCHING_LIST=`seq 0 3 $RANGEMAX`
	fi
else
	FR_FETCHING_LIST=$SINGLE_FORECAST_RANGE
fi

function get_indo() {

	url_filter="http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_hd.pl?file=gfs.t${RUN}z.mastergrb2f$i&all_lev=on&all_var=on&subregion=&leftlon=$leftlon&rightlon=$rightlon&toplat=$toplat&bottomlat=$bottomlat&dir=%2Fgfs.$TODAY%2Fmaster"
	wget --limit-rate=800k -O $GFSTMP/$GFSFILE "$url_filter" | tee $LOGFILE 
	SOURCE=$url_filter
}


function get_mirror() {
	url_mirror="http://172.19.22.69/mirror/gfs/gfs.$TODAY/master/gfs.t${RUN}z.mastergrb2f$i"
	wget -O $GFSTMP/$GFSFILE "$url_mirror" | tee $LOGFILE 
	SOURCE=$url_mirror
}
 
function get_full() {
	url_full="http://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$TODAY/master/gfs.t${RUN}z.mastergrb2f$i"
	wget --limit-rate=800k -O $GFSTMP/$GFSFILE "$url_full" | tee $LOGFILE 
	
	SOURCE=$url_full
}

for i in $FR_FETCHING_LIST ; do
	i=`printf "%.2d" "$i"`
	GFSFILE=GFS.$TODAY.mastergrb2f$i.grb2

	if [ -f $GFSHOLD/$GFSFILE ]; then
		sizeGFSFILE=`sizeOf $GFSHOLD/$GFSFILE`
	else
		sizeGFSFILE="0"
	fi

	## check for null sizes of file in holdspace
	if [ -f $GFSHOLD/$GFSFILE ] && [ $sizeGFSFILE -gt 1 ]; then
		echo "Linking $i from HOLDSPACE : " | tee $LOGFILE
		if [ ! -f $GFSDIR/$GFSFILE ]; then
			echo "ln $GFSHOLD/$GFSFILE $GFSDIR" | tee $LOGFILE
			ln $GFSHOLD/$GFSFILE $GFSDIR
		fi
		continue
	else
		if [ $sizeGFSFILE -eq 0 ]; then
			echo "$GFSFILE is of null file size. Refetching..." | tee $LOGFILE
		fi
		echo "Fetching $i from $url : " | tee $LOGFILE

		# missing SKINTEMP  : url_full="http://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$TODAY/gfs.t${RUN}z.pgrb2bf$i"


		set -x
	
		case $get_model in 	

			Lget_full)
				get_full ;;
			Lget_indo)
				get_indo ;;
			Lget_mirror)
				get_mirror ;;
			*)
				echo "Fetching from unknown source... abort"
				exit 1 ;;
		esac

	
		## check for null sizes of downloaded file
		sizeGFSFILE=`sizeOf $GFSTMP/$GFSFILE`

		if [ -f $GFSTMP/$GFSFILE ] && [ $sizeGFSFILE -gt 0 ]; then
			echo "Copying $i to $GFSDIR for scanning " | tee $LOGFILE
			ln $GFSTMP/$GFSFILE $GFSDIR
		else	
			echo "File not downloaded or size = 0. Exiting!" | tee $LOGFILE
			exit 666
		fi
	fi
done

exit 0

