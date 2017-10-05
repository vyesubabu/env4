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

## Transmet Config
TRANSMET=192.168.2.53
TRANSMET_ALT=192.168.14.53
login=ftp
password=ftp
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

## Sending to TRANSMET
ftp -n -i $TRANSMET <<EOF
user $login $password
cd $QLM_ENTRY_PATH
ascii
put $headerfile
EOF

## Removing link
rm $headerfile

