#!/bin/bash
#
# This script processes METv4 output
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Dec, 19  2012     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.1 : 20130125						      # 
#		- Add ALPHA coeff to list				      #
#	* v1.0 : 20121219						      # 
#		- init							      #
#									      #
#   LATEST MODIFICATIONS :					  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

DEBUG=1
DEBUG=0
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
function detail_header() {
	f=$1
	cat $f |head -1|sed "s:  *:\n:g"|awk '{print NR,$1}'
}


### MAIN

statfile=$1

if [[ $DEBUG -eq 1 ]]; then
	detail_header $statfile
	echo "Select column numbers you want to print (separated by blank space):"
fi

#read columnlist

#columnlist='9" "10" "11" "12" "23" "33" "63" "75'
#columnlist='9" "10" "23" "33" "28" "38" "63" "75'
columnlist='4" "5" "9" "10" "20" "22" "23" "33" "28" "38" "53" "75'
dolarCL=`echo $columnlist |sed -e 's: "\([0-9]\): "$\1:g' -e "s:^:$:g"`

if [[ $DEBUG -eq 1 ]]; then
	echo $dolarCL
fi
cat $statfile | awk '{print '"$dolarCL"' }'
exit 0
for column in $columnlist ; do

 	cat $statfile | awk '{print $'$column'}'
	echo ""

done


