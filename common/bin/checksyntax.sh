#!/bin/bash
#
# This script does stuff
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Feb, 08  2012     #
#                                                                             #
#   VERSION :								      #
#	* v1.0 : 2012xx							      # 
#		-							      #
#									      #
#   LATEST MODIFICATIONS :					  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
file=$1

echo "Non closed double quotes: "
cat $file |grep '"' | grep -v '".*"'


echo "Non closed back quotes: "
cat $file |grep '`' | grep -v '`.*`'

echo "Two pipes in a row: "
cat $file |grep '|[ ]*|'
