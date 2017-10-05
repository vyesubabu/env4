#!/bin/bash
#
# This script splits a big file into chunks to send to TRANSMET
# and adds a header to each file
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Nov, 13  2013     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0: 20131113						      # 
#		- Init							      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

file2split=$1
ENTETE=$2
CIPS_SEND=/common/bin/cips_send.py

if [ -z "$file2split" ]; then
	echo "Missing file2split as arg#1"
	exit 1
fi
if [ -z "$ENTETE" ]; then
	echo "Missing Header as arg#2"
	exit 1
else 
	LENGTH_HEADER=`echo ${#ENTETE}`
	if [ $LENGTH_HEADER -eq 10 ]; then
	
		echo "Header is of the right format"
		export TTAAii=`echo $ENTETE | cut -c1-6`
		export CCCC=`echo $ENTETE | cut -c7-10`
	else
		echo "Header $ENTETE is NOT of the right format (10 chars)"
		exit 1
	fi	
fi


## split by 1Go
echo "Splitting $file2split.."
PREFIX=${ENTETE}_file
split -b1G -d $file2split $PREFIX

## Checksum
md5sum ${PREFIX}* > ${PREFIX}.md5sum

## Build filelist to send, including checksum
FILELIST=`ls -1 ${PREFIX}*`
#FILELIST="$FILELIST $PREFIX.md5sum"

for f in $FILELIST;do 
	
	echo "Uncomment the line to send :"
	echo "$CIPS_SEND --mode transmet-header --header ${TTAAii} --center ${CCCC} --files $f --debug"
	#$CIPS_SEND --mode transmet-header --header ${TTAAii} --center ${CCCC} --files $f --debug

done

