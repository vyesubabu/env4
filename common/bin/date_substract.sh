#!/bin/bash
#
# This script does date substractions and returns the difference in seconds
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTEUR: REMI MONTROTY                                   Jan, 01  2012     #
#                                                                             #
#   VERSION :								      #
#	* v1.0								      # 
#		-							      #
#									      #
#   LATEST MODIFICATIONS :					  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

date14tofmt () {
	D=$1
	date -u -d "${D:0:8} ${D:8:2}:${D:10:2}:${D:12:2}" +%s 
}
date2stamp () {
    date -u --date "$1" +%s
}
dateDiff (){
    #dte1=$(date2stamp $1)
    #dte2=$(date2stamp $2)
    dte1=$1
    dte2=$2
    diffSec=$((dte2-dte1))
    if ((diffSec < 0)); then abs=-1; else abs=1; fi
    echo $((diffSec*abs))
}
usage () {
	echo "$0 date1 date2"
	echo "(in YYYYMMDDhhmmss format)"
}

#############################################################
#
#		MAIN PROGRAM
#
#############################################################
date1=$1
date2=$2

if [ -z "$date1" ] || [ -z "$date2" ]; then
	usage
	exit 1
fi

d1fmt=`date14tofmt $date1`
d2fmt=`date14tofmt $date2`

dateDiff "$d1fmt" "$d2fmt"
