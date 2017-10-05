#!/bin/bash
#
# This script sends QLM cyclone tracks to TRANSMET. 
# 
# WARNING: DO NOT EDIT HEADERS MANUALLY AT THE RISK OF CAUSING PROBLEMS
#          IN TRANSMET SERVERS
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTEUR: REMI MONTROTY                                   Jun, 02  2010     #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#   transmet_send.sh PHAT.20100601.QLM.txt                                    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
set +x
file=$1

if [ -z "$file" ]; then
	echo "No file passed as argument"
	echo "Use: transmet_send.sh somecyclonetrackfile.txt"
	exit 1
fi
##############################################################################
##
##  NO EDITING BELOW THIS LINE UNLESS CONCERTED WITH TRANSMET ADMINISTRATORS
##
##############################################################################

## Check that file is ASCII & contains the appropriate number of lines
ft=`file $file|grep -o ASCII`
if [ "$ft" == "ASCII" ]; then
	nl=`cat $file | wc -l`
	if [ $nl -ne 16 ] ; then
		echo "File is ASCII but does not contain the expected header"
		echo " "
		echo "Header : "
		echo "SYSTEM_NAME"
		echo "QLM"
		echo "YYYYMMDDHH"
		echo "0		LAT		LON"
		echo "6		LAT		LON"
		echo "12	LAT		LON"
		echo "18	LAT		LON"
		echo "24	LAT		LON"
		echo "30	LAT		LON"
		echo "36	LAT		LON"
		echo "42	LAT		LON"
		echo "48	LAT		LON"
		echo "54	LAT		LON"
		echo "60	LAT		LON"
		echo "66	LAT		LON"
		echo "72	LAT		LON"
		echo ""
		echo "Aborting"
		exit 1
	fi

else
	echo "File is not of ASCII type. Aborting"
	exit 1
fi

login=ftp
password=ftp
TRANSMET=192.168.2.53
TRANSMET_ALT=192.168.14.53
#QLM_ENTRY_PATH=entree.alpha/QLM
QLM_ENTRY_PATH=entree.fac/CIPS


## Header file definition
TTAAII=ZCPR00
CCCC=CIPS
SEND_DATE=`date -u +%Y%m%d%H%M%S`
VALIDITY_DATE=`sed -n '3 p' < $file`
if [ ${#VALIDITY_DATE} -ne 10 ]; then 
	echo "Date found inside file $file : $VALIDITY_DATE"
	echo "Should be in YYYYMMDDHH format, please check"
	exit 1
fi
## For PrdDB 
KEY1=CYCLONE
KEY2=Tracks
KEY3=FromQLM

## Linking file
headerfile="T_${TTAAII}_C_${CCCC}_${SEND_DATE}_${VALIDITY_DATE}_${KEY1}_${KEY2}_${KEY3}_$file"
ln -s $file $headerfile
echo "Sending $headerfile to TRANSMET..."

## Sending to TRANSMET
ftp -n -i $TRANSMET <<EOF
user $login $password
cd $QLM_ENTRY_PATH
ascii
put $headerfile
EOF

## Removing link
rm $headerfile

