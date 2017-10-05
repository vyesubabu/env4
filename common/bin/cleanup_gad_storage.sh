#!/bin/bash
#
# This script cleans gad storage dir to remove old advisories
# to avoid GAD crashes..
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Mar, 27  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.1: 20140402						      # 
#		- Remove empty dirs					      #
#	* v1.0.0: 20140327						      # 
#		- Init							      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

GAD_STORAGE_DIR=/home/sms/journal/sms/storage/gad

RETENTION_DAYS=15
cd $GAD_STORAGE_DIR
echo "working in $PWD"

echo "Finding files"
find . -mtime +$RETENTION_DAYS -type f
echo "Deleting files"
find . -mtime +$RETENTION_DAYS -type f| xargs rm -rf 
find . -type d -empty| xargs rm -rf

