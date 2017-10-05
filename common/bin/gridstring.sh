#!/bin/bash
#
# This script reads in a model (grib1) & writes out a string describing the grid
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Nov, 11  2012     #
#                                                                             #
#   VERSION :								      #
#	* v1.2.1 : 20140904						      # 
#		- grib_api 1.12.1 + MODULEPATH
#	* v1.2.0 : 20140410						      # 
#		- Revisit for miniHPC indo
#	* v1.1 : 20121219						      # 
#		- add FR
#		- remove accumulations from FR (grep -v [-])
#	* v1.0 : 20121127						      # 
#		- init for center+subcenter+process			      #
#		- init for latlon + grid				      #
#									      #
#   LATEST MODIFICATIONS :					  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  gridstring.sh somefile.grb                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

set +x 
file=$1
base=`basename $file`
FILELISTING=/tmp/$base.list
#WGRIB=/common/bin/wgrib
#WGRIB=/home/montrotyr/bin/wgrib
#WGRIB2=/common/bin/wgrib2

# Start with loading modules
. /etc/profile.d/modules.sh
export MODULEPATH=$MODULEPATH:/cm/shared/modulefiles
module load taskcenter/common
module load grib_api/1.12.1

WGRIB=`which wgrib`
WGRIB2=`which wgrib2`

if [ -z "$WGRIB" ] ||  [ -z "$WGRIB2" ]; then
	WGRIB=/common/bin/wgrib
	WGRIB2=/common/bin/wgrib2

	if [ ! -f $WGRIB ] || [ ! -f $WGRIB2 ]; then
		#echo "wgrib and/or wgrib2 not found. Aborting"
		exit 1
	fi
fi

$WGRIB -V $file 1> $FILELISTING 2> /dev/null

#$WGRIB2 -V $file 1> $FILELISTING.2 2> /dev/null
#cat  $FILELISTING.2  >> $FILELISTING 
#echo 'finished with listing'

typeGrib=`cat $FILELISTING | grep -i latlon| sed -e "s: lat .*::g" -e "s: :_:g" | sort -u`

### BUILD CSPstring
#Center-SubCenter-Process string (CSPstring)
CSPstring=`cat $FILELISTING |grep center|awk '{print $2"-"$4"-"$6}'|sort -u|head -1`

### BUILD LLGstring
case $typeGrib in
	 "__latlon:") 
	LLGstring=`cat $FILELISTING |grep "latlon: lat" -A 2 |sed -n 'N;s/latlon://;s/\n//;p'|grep nxny|awk '{print "LAT"$2$4"_LON"$10$12"_GRID"$14}' |sed "s:,::g" |sort -u`
	;;

	"__rotated_LatLon_grid_")
	LLGstring=`cat $FILELISTING |grep -i LatLon -A2 | sed -n 'N; s/rotate LatLon grid:// ; s/\n// ; p'|grep nxny | awk '{print "LAT"$5$7"_LON"$9$11"_GRID"$18}'|sort -u`
	;;
esac

### BUILD FRstring
#set -x
FR=`grib_ls -p stepRange $file |grep -v "[a-Z\-]"| grep -v "^$" | sort -u |sed "s: *::g"`
FRstring="FR_$FR"

echo ${CSPstring}_${LLGstring}_$FRstring

rm -f $FILELISTING
