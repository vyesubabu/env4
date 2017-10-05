#!/bin/bash


function use() {
echo "$0 DOMAIN YYYYMMDDHH opt:SINGLEFR"
}

DOMAIN=$1
RUNDATE=$2

## Optional 
SINGLE_FORECAST_RANGE=$3

if [ -z $1 ] ; then
	use
	exit 1
fi

RANGEMAX=72

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

GFSHOLD=/tmp/remi
GFSDIR=/tmp/remi

mkdir -p $GFSDIR
mkdir -p $GFSHOLD

NLFILE=$WRF_HOME/WPS/domains/$DOMAIN/namelist.wps

leftlon=`cat $NLFILE | grep gfsdomain | awk '{print $5}'`
rightlon=`cat $NLFILE | grep gfsdomain | awk '{print $4}'`
toplat=`cat $NLFILE | grep gfsdomain | awk '{print $2}'`
bottomlat=`cat $NLFILE | grep gfsdomain | awk '{print $3}'`

case $DOMAIN in 
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
if [ -z "$SINGLE_FORECAST_RANGE" ] ; then
	## we do not run in single forecast range extraction mode
	FR_FETCHING_LIST=`seq 0 3 $RANGEMAX`
else
	FR_FETCHING_LIST=$SINGLE_FORECAST_RANGE
fi

function get_indo() {

		url_filter="http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_hd.pl?file=gfs.t${RUN}z.mastergrb2f$i&all_lev=on&all_var=on&subregion=&leftlon=$leftlon&rightlon=$rightlon&toplat=$toplat&bottomlat=$bottomlat&dir=%2Fgfs.$TODAY%2Fmaster"
		wget --limit-rate=800k -O $GFSDIR/$GFSFILE "$url_filter" | tee $LOGFILE 
}
 
function get_full() {
		url_full="http://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$TODAY/master/gfs.t${RUN}z.mastergrb2f$i"
		wget --limit-rate=800k -O $GFSDIR/$GFSFILE "$url_full" | tee $LOGFILE 
}
for i in $FR_FETCHING_LIST ; do
	i=`printf "%.2d" "$i"`
	GFSFILE=GFS.$TODAY.$i.grb2
	sizeGFSFILE=`cat $GFSHOLD/$GFSFILE | wc -c`

	## check for null sizes of file in holdspace
	if [ -f $GFSHOLD/$GFSFILE ] && [ $sizeGFSFILE -gt 0 ]; then
		echo "Linking $i from HOLDSPACE : " | tee $LOGFILE
		echo "ln $GFSHOLD/$GFSFILE $GFSDIR" | tee $LOGFILE
		ln $GFSHOLD/$GFSFILE $GFSDIR
		continue
	else
		if [ $sizeGFSFILE -eq 0 ]; then
			echo "$GFSFILE is of null file size. Refetching..." | tee $LOGFILE
		fi
		echo "Fetching $i from NCEP : " | tee $LOGFILE

		# missing SKINTEMP  : url_full="http://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$TODAY/gfs.t${RUN}z.pgrb2bf$i"
	
		case $get_model in 	
			Lget_full)
			get_full ;;
			Lget_indo)
			get_indo ;;
		esac

	
		## check for null sizes of downloaded file
		sizeGFSFILE=`cat $GFSDIR/$GFSFILE | wc -c`
		if [ -f $GFSDIR/$GFSFILE ] && [ $sizeGFSFILE -gt 0 ]; then
			echo "Copying $i to HOLDSPACE (in case of relaunch)" | tee $LOGFILE
			ln $GFSDIR/$GFSFILE $GFSHOLD
		else	
			echo "File not downloaded or size = 0. Exiting!" | tee $LOGFILE
			exit 666
		fi
	fi
done

cd $WRF_HOME/WPS/domains/$DOMAIN 

rm -f ./GRIBFILE.*
./link_grib.csh ./COUPLING_FILES/*

exit 0

