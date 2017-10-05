#!/bin/bash
#
# This script sends the postprocessed files to CIPS 
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Dec, 14  2011     #
#                                                                             #
#   VERSION :								      #
#	* v1.0								      # 
#		- For resending files to CIPS   			      #
#									      #
#   LATEST MODIFICATIONS :					  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  send2cips.sh  *.grb
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


if [ -z "$*" ] ; then
	echo "Use is : 	send2cips.sh DMT_DATE_PIVOT TYPE DOMAIN"
	exit 1
fi

FILES2XFER=$*

## YOu should be in local directory of the files
#cd /share/scratch/SMS/sms/holdspace/$MODEL/$GRID/$date/out

#for f in $FILES2XFER; do
#	nf=$MODEL.$GRID.$f.LT
#	ln -s $f $nf
#	## add file to list to be transfered
#	FILES2SYN="$FILES2SYN $nf"
#done

#SYN_IPS="192.168.1.15"
IPS="192.168.1.101 192.168.1.102"

for ip in $IPS; do
	echo "Sending to $ip"
	ncftpput -S .tmp -u cips_in -p cips_in $ip ./moddb $FILES2XFER
done

## cleanup

