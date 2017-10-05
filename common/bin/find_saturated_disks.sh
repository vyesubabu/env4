#!/bin/bash
#
# This script does stuff
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0: 20140101						      # 
#		-							      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
ERROR=0
base=`basename $0`
LOG=/tmp/$base.list

pexec "df -h"| grep "[789][0-9]%" > $LOG

LIST=`cat $LOG`

if [ ! -z "$LIST" ]; then

	echo "Some partitions are getting full. Act now"
	cat $LOG
	ERROR=2

fi


# cleanup 
rm -f $LOG

exit $ERROR
