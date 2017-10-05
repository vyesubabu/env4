#!/bin/bash
#
# This script replaces symlinks in current dir 
# by actual copies of the file linked to
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2012     #
#                                                                             #
#   VERSION :								      #
#	* v1.0 : 20130402						      # 
#		-	init						      #
#									      #
#   LATEST MODIFICATIONS :					  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

dir=$PWD

CHANGE="ON"
CHANGE="OFF"

if [ ! -z "$1" ]; then
	CHANGE=$1
fi

for link in $(find $dir -maxdepth 1 -type l) ; do
	  loc=$(dirname $link)
	  linkname=$(basename $link)
	  dir=$(readlink $link)
	 # echo "$link $loc $dir $linkname"
	  echo "rm $link"
	  echo "cd $loc"
	  echo "cp $dir ./$linkname"

	if [ "$CHANGE" == "ON" ]; then
	  rm $link
	  cd $loc
	  cp $dir ./$linkname
	fi
  	echo ""
done
