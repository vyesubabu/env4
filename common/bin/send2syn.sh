#!/bin/bash
#
# This script sends the postprocessed files to SYNERGIE stations
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Nov, 24  2011     #
#                                                                             #
#   VERSION :								      #
#	* v1.0								  # 
#		-							  #
#									  #
#   LATEST MODIFICATIONS :					  	#
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  send2syn.sh $DMT_DATE_PIVOT $TYPE $DOMAIN
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

date=$1
MODEL=$2
GRID=$3

if [ -z "$date" ] ||  [ -z "$MODEL" ] ||  [ -z "$GRID" ] ; then
	echo "Use is : 	send2syn.sh DMT_DATE_PIVOT TYPE DOMAIN"
	exit 1
fi

#date=20111124000000
#MODEL=COSMO
#MODEL=HRM
#GRID=KNEW0140
#MODEL=COSMO
#GRID=KNEW0070

if [ -z "$FILES2XFER" ]; then
	echo "Files to send are not set in the environment as variable FILES2XFER. Pls check"
	exit 1
else
	echo "Sending the following files: $FILES2XFER"
fi

cd /share/scratch/SMS/sms/holdspace/$MODEL/$GRID/$date/out

FILES2SYN=""
for f in $FILES2XFER; do
	nf=$MODEL.$GRID.$f.LT
	ln -s $f $nf
	## add file to list to be transfered
	FILES2SYN="$FILES2SYN $nf"
done

SYN_IPS="192.168.1.15"
SYN_IPS="192.168.1.15 192.168.1.16"

for ip in $SYN_IPS; do
	echo "Sending to $ip"
	ncftpput -S .tmp -u retim2000 -p retim2000 $ip ./ $FILES2SYN
done

## cleanup
rm -f *.LT

