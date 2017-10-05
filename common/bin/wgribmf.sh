#!/bin/bash
#
# This script does stuff
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Dec, 12  2012     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.1 : 20140822						      # 
#		- Update with grib_api 1.12.1 on IMP			      #
#	* v1.0 : 20121207						      # 
#		-							      #
#									      #
#   LATEST MODIFICATIONS :					  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function grib_api_module() {
# replaces selectLatestGribApi
	. /etc/profile.d/modules.sh
	module load taskcenter/common
	#module load taskcenter/softwares/grib_api
 #	module load grib_api/1.10.0
	module load grib_api/1.12.1

	latest=`which grib_info`
	GRIB_API_DIR=`dirname $latest`
	GRIB_API_VERSION=`$latest -v` 

	echo "Selected grib_api version $GRIB_API_VERSION from $GRIB_API_DIR"
}


function selectLatestGribApi() {

	GRIBINFOS=`locate grib_info|grep bin`
	for g in $GRIBINFOS; do 
		version=`$g -v`; 
		echo $g $version >> gribinfos.list; 
	done
	latest=`cat gribinfos.list |sort -k 1|tail -1|awk '{print $1}'`

	GRIB_API_DIR=`dirname $latest`
	GRIB_API_VERSION=`$latest -v` 

#	echo "Selected grib_api version $GRIB_API_VERSION from $GRIB_API_DIR"

	# cleanup
	rm -f gribinfos.list
}

### Main
file=$1
out=$2

if [ -z "$file" ] ;then
	echo "File $file missing... call :$0 some_mf_gribfile out.grib1"
	exit 1
fi
if [ -z "$out" ] ;then
	echo "Picking default output name= $file.grib1"
	out=$file.grib1
fi

#~~
#selectLatestGribApi
grib_api_module

if [ ! -f $out ]; then
	#
	$GRIB_API_DIR/grib_set -r -s packingType=grid_simple $file $out
fi

