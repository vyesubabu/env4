#!/bin/bash
#
# This script shows your .def file structure prior to  publishing into CDP
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Feb, 20  2015     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0: 20150220						      # 
#		- Init							      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

echo "use with $0 file mode=(basic||advanced||triggers)"
file=$1
mode=$2

case $mode in
	basic) 
		cat $file |grep -w "family" ;;
	advanced) 
		cat $file |grep -w "family\|suite\|endfamily" ;;
	triggers) 
		cat $file |grep -w "family\|resources\|suite\|endfamily\|trigger" ;;
	
esac

