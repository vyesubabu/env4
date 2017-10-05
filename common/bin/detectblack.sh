#!/bin/bash
#
# This script takes a list of files as input, detects the black ones
# and returns the list of non black ones
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Dec, 01  2012     #
#                                                                             #
#   VERSION :								      #
#	* v1.0 : 20121122						      # 
#		- Init 							      #
#									      #
#   LATEST MODIFICATIONS :					  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#   detectblack.sh meteosat-highrate_hrvFog_201211220*                 	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

FILELIST=$*
NONBLACK_FL=""

DEBUG='ON'
DEBUG='OFF'

# Arbitrary.. based on means of hrvFog images
ALLBLACK_THRESHOLD=1000.0

for f in $FILELIST ; do 
	mean=`convert $f -format "%[mean]" info:`; 
	#echo $f " mean="$mean; 

	# Will return "BLACK" if the image is deemed black!
	# else will return empty string if image is ok.
	BLACKORNOT=`echo $mean $ALLBLACK_THRESHOLD | awk '{if ( $1 <= $2 ) { print "BLACK"}}'`

	if [ -z "$BLACKORNOT" ]; then
		NONBLACK_FL="$NONBLACK_FL $f"
	else
		if [ "$DEBUG" == "ON" ];then
			echo "$f is black!"
		fi
	fi
done
echo "$NONBLACK_FL"

