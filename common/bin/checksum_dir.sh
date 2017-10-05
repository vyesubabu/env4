#!/bin/bash
#
# This script does stuff
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2013     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0: 20130101						      # 
#		-							      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
dir=$1


function usage() {
	echo "Call with: $0 dir "
}

if [ -z "$dir" ]; then
	usage
	exit 1
fi

DIRSUM=`ls -alR $dir | md5sum`
NFILES=`find $dir -type f | wc -l`
NDIR=`find $dir -type d | wc -l`

echo "Checksum of $dir:  $DIRSUM"	
echo "Counting $NDIR dirs, with $NFILES files"
