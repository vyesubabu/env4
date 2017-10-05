#!/bin/bash
#
#
# This script generates a list of dates based on 3 parameters.
# the increment INC units are defined based upon the last unit given by
# the date i.e. YYMMDD[HH][mm][ss] where hours, minutes and seconds 
# are facultative.
#
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2010     #
#                                                                             #
#   VERSION :								      #
#	* v1.1.0: 20131126						      # 
#		- Add usage()						      #
#	* v1.0.0: 20100416						      # 
#		- Init							      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  gen_datelist.bash 200511051200 200511061330 30 minutes		      #
#  gen_datelist.bash DATEBEGIN DATEEND INC INC_UNIT
#                                                                             #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
module load taskcenter/common
. $COMMON_HOME/bin/cips_bash_functions.sh


function usage() {

  echo "Usage: $0 DATEBEGIN DATEEND INCREMENT INCREMENT_UNIT"
  echo "ex: $0 20131101 20131130 1 days"
  echo "ex: $0 20131101 20131130 12 hours"
  echo "ex: $0 20131101 20131130 30 minutes"
}

set +x
dpp='date -u'

DATEDEB=$1
DATEFIN=$2
INC=$3
INC_UNIT=$4
if [ -z "$DATEDEB" ] || [ -z "$DATEFIN" ]; then
	usage
	exit 1
fi
if [ -z "$INC_UNIT" ]; then
	INC_UNIT="days"
fi

D_LENGTH=${#DATEDEB}
DF_LENGTH=${#DATEFIN}

if [ "${D_LENGTH}" == "${DF_LENGTH}" ]; then
    case ${D_LENGTH} in
        8) DATEDEB=${DATEDEB}000000;DATEFIN=${DATEFIN}000000;if [ -z "${INC}" ];then INC=1; fi ;;
        10) DATEDEB=${DATEDEB}0000;DATEFIN=${DATEFIN}0000;if [ -z "${INC}" ];then INC=1; fi;;
        12) DATEDEB=${DATEDEB}00;DATEFIN=${DATEFIN}00; if [ -z "${INC}" ];then INC=5; fi;;
        14) if [ -z "${INC}" ];then INC=1; fi;;
    esac
else
	echo "The two dates are not of same length. Please change."
	exit 1
fi

DATE=`echo $DATEDEB`
DATEFIN_C=`echo $DATEFIN`

while [[ $DATE -le $DATEFIN_C ]]; do
	echo $DATE
	FMTDATE=`date14_to_fmt $DATE`
    	DATEPLUS=`$dpp --date="$FMTDATE GMT +$INC $INC_UNIT" +"%Y%m%d%H%M%S"`
	DATE=`datefmt_to_14 $DATEPLUS`
done
