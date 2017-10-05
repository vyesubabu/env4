#!/bin/bash
#
# This script takes a MODEL input file and converts it so that params that can be 
# displayed in Synergie are converted to a suitable gribcode/table number
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Feb, 15  2012     #
#
#   REQS: grib_api compiled (grib_set binary)
#                                                                             #
#   VERSION :								      #
#	* v1.3 : 20120227						      # 
#		- Added test on existing output file (skip & exit)
#		- Added removal of WORKDIR as cleanup
#	* v1.2								      # 
#		- Added 143.201, 145.201 for HRM/COSMO CAPE
#	* v1.1								      # 
#		- Renamed MODEL2SYN.sh
#	* v1.0								      # 
#		- Start with CAPE
#									      #
#   Possible upgrades :						  	      #
#		- Extend it to any incoming model
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  MODEL2SYN.sh wrfprs_d02.035-datapolicy.grb wrfprs_d02.035-synready.grb
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
set +x

## INPUT SPECS
# unused WGRIB=/share/common/bin/wgrib
WORKDIR=/tmp/MODEL2SYN.$$
GRIB_SET=/share/common/bin/grib_set

GRIBCODES_TO_PROCESS="157.2"
GRIBCODES_TO_PROCESS="157.2 143.201 145.201"


grib_in=$1
grib_out=$2

#~~~~~~~~~~~~~~Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

## F1:
usage() { 
  echo "Use: $0 grib_in grib_out"
}


## F2:
check_varnull() { 
  varname=$1
  varvalue=`eval echo \\\$$varname`
	
  if [  -z  "$varvalue" ]; then
	usage
	echo "Variable $varname not set. Aborting"
	exit 1
  fi
}

## F3:
parse_gribcode() {

	gc=$1

	## Set default value to see if gribcode shall be skipped
	SKIP="NO"

	case $gc in 
		157.2) 		ngc=160.1 ; echo "Encoding CAPE for Synergie" ;;
		143.201) 	ngc=160.1  ; echo "Encoding CAPE for Synergie";;
		145.201) 	ngc=160.1  ; echo "Encoding CAPE for Synergie";;
		*)		echo "unknown gribcode $gc to process. No matching element for Synergie" ; SKIP="YES";;
	esac

	NEWGRIBCODE=`echo ${ngc%%.*}`
	NEWTABLE=`echo ${ngc##*.}`

	conversion_string="table2Version=${NEWTABLE},indicatorOfParameter=${NEWGRIBCODE} -w param=${gc}"

}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
check_varnull grib_in
check_varnull grib_out

if [ -f $grib_out ] && [ -s $grib_out ]; then
	echo "                            "
	echo "           WARNING          "
	echo "                            "
	echo "$grib_out already exists. Skip it"
	exit 2
fi

[[ -d $WORKDIR ]] || mkdir -p $WORKDIR

WORK_GRIB=$grib_in

for GRIBCODE in $GRIBCODES_TO_PROCESS; do

	parse_gribcode $GRIBCODE

	## Set Originating Center code to local center
	if [ "$SKIP" == "NO" ];then

		echo " $GRIB_SET -s ${conversion_string} $WORK_GRIB  $grib_out"
		$GRIB_SET -s ${conversion_string} $WORK_GRIB  $WORKDIR/tmpgrib
		
		## update WORK_GRIB
		mv $WORKDIR/tmpgrib $WORKDIR/work.grb
		WORK_GRIB=$WORKDIR/work.grb
	else
		echo "Skipping the processing of $GRIBCODE"
	fi

	echo ""
done

mv $WORK_GRIB $grib_out

if [ ! -z "$WORKDIR" ];then
   rm -rf $WORKDIR
fi
