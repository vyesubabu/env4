#!/bin/bash
#
# This script converts a geostationary image & reprojects it to latlon domain
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2012     #
#                                                                             #
#   VERSION :								      #
#	* v1.1 : 20121122						      # 
#		- add NO_CLEANUP as $2 option to keep globe.*.geotiff
#	* v1.0 : 20121115						      # 
#		- Add DOMAIN as $2					      #
#									      #
#   LATEST MODIFICATIONS :					  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  cropGeostationary.sh file.tif 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function usage() {
	echo "Correct call : $0 someGeostationaryTiffMF "
	exit 1
}
function defaultglobe() {
	globe=$1
	case $globe in 
		globeC)
			centerPointLongitude=145 
			;;
			
		globeM)
			centerPointLongitude=0

			;; 

		globeE)
			centerPointLongitude=-75

			;; 

		globeI)
			centerPointLongitude=63

			;; 

		*) 
			echo "Wrong globe type..."
			exit 1;;
	esac

	let WLON=centerPointLongitude-20
	let ELON=centerPointLongitude+20
	WLAT=-20
	ELAT=+20
	DEFAULT_STRING="$WLON $WLAT $ELON $ELAT"
}



function selectdomain() {

	if [ -z "$DOMAIN" ]; then
		echo "Which domain do you want?"
		echo $DOMAINLIST
		echo "Note that you may specify your own domain name now:"
		read DOMAIN

		if [ -z "$DOMAIN"  ];then
			DOMAIN="default"
		fi
	fi

	case $DOMAIN in 
		"Djibouti")
			DOMAIN_STRING="36 7 53 15" ;;
		"DjiboutiLarge")
			DOMAIN_STRING="36 0 58 22" ;;
		"France")
			DOMAIN_STRING="-10 30 20 60" ;;
		"MidAfrica")
			DOMAIN_STRING="-30 -30 30 30" ;;
		"NO_CLEANUP")
			CLEANUP="NO" ;;
		"default")
			echo "using default string $DEFAULT_STRING"
			DOMAIN_STRING="$DEFAULT_STRING" ;;
		*)
			echo "What is this domain $DOMAIN??"
			echo "Please enter domain boundaries : SouthWest_Longitude Southwest_Latitude Northeast_Longitude Northeast_latitude"
			echo "e.g.:"
			echo "-30 -30 30 30"
			read DOMAIN_STRING ;;
	esac

}




#############################################################""
#
#                   MAIN
#

# module..
. /etc/profile.d/modules.sh
module load taskcenter/common
module load taskcenter/gdal
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"

# Define binaries
TIFFMF2GEOTIFF="/common/bin/tiffmf2geotiff"
GDALWARP=`which gdalwarp`
#GDALWARP="/common/bin/gdalwarp"
CLEANUP="YES"

DOMAINLIST="Djibouti DjiboutiLarge MidAfrica France default"

Path2fileTiffMF=$1
DOMAIN=$2


WORKDIR=`dirname $Path2fileTiffMF`
cd $WORKDIR
fileTiffMF=`basename $Path2fileTiffMF`

echo "dir="$WORKDIR" file="$fileTiffMF 
#exit 1

## Consistency checks
if [ -z "$GDALWARP" ]; then
	echo "GDAL not setup properly... check module load gdal "
	exit 1
fi

if [ -z "$fileTiffMF" ]; then
	usage
else 
	base=`basename $fileTiffMF .tif`
	globeX=`echo $base | cut -c1-6`
	defaultglobe $globeX
fi
fileGeoTiff=$base.geotiff

#~
selectdomain

# Save used domains
#echo "$DOMAIN $DOMAIN_STRING" >> /tmp/$0.domainlist

# Exit file based on $DOMAIN string
LatLonFile=`echo $fileGeoTiff | sed "s:globe.:$DOMAIN:g"`

# Convert to geotiff
$TIFFMF2GEOTIFF $fileTiffMF $fileGeoTiff

# Interpolate to lat-lon 
rm -f $LatLonFile
echo " $GDALWARP -t_srs '+proj=latlong' -te $DOMAIN_STRING $fileGeoTiff $LatLonFile "
$GDALWARP -t_srs '+proj=latlong' -te $DOMAIN_STRING $fileGeoTiff $LatLonFile

# Visualize
#eog $LatLonFile

# Cleanup
if [ "$CLEANUP" == "YES" ]; then
	rm -f $fileGeoTiff
fi
