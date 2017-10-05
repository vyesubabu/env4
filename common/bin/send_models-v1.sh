#!/bin/bash
#
# This script sends the files to remote systems (CIPS / SYNERGIE)
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Dec, 14  2011     #
#                                                                             #
#   VERSION :								      #
#	* v1.7 : 20120220						      # 
#		- Debug GB of -datapolicy.grb				      #
#		- clean-up -synready.grb				      #
#		- use $NCFTPPUT						      #
#	* v1.6 : 20120217						      # 
#		- Clarifiy SEND_ALL usage				      #
#		- Clean up claude's trace				      #
#	* v1.5 : 20120215						      # 
#		- Add calls to WRF2Synergie.sh prior to sending		      #
#		- Cleanup
#	* v1.4 : 20120116						      # 
#		- Change cleaning of .GB to nada			      #
#		- added "ALL" target
#	* v1.3 : 20120105						      # 
#		- Change cleaning of .GB to only current GBLIST to prevent    #
#		  UNIPOST from erasing another unipost file		      #
#	* v1.2 : 20111221						      # 
#		- add SEND_ALL option					      #
#		- switch to .GB extension files for Synergie		      #
#	* v1.1								      # 
#		- ncftpput error codes summed up (instead of exiting on       #
#		  first failure to xfer files				      #
#	* v1.0								      # 
#		- Take MODEL / GRID arguments to send files		      #
#		- for COSMO/HRM : DEFAULT_FILENAME must be in ENV	      #
#		as given from user_model_post				      #
#									      #
#   Possible Evolutions :					  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  send_models.sh WRF KNEW0070 CIPS 20111219000000                    	      #
#  send_models.sh HRM KNEW0140 SYNERGIE 20111219000000                 	      #
#  send_models.sh HRM KNEW0140 SYNERGIE 20111221000000 SEND_ALL      	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

WRF2SYN=/share/apps/WRF/oper/scripts/WRF2Synergie.sh
NCFTPPUT=/share/common/bin/ncftpput
SENDMODELS_LOG=/home/sms/journal/cips_send/cips_send.log

MODEL=$1
GRID=$2
RANGE_LIST_TYPE=$3
TARGET=$RANGE_LIST_TYPE
DATE=$4
SEND_ALL=$5



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#  Functions

usage() {
echo "Call : $0 MODEL GRID CIPS|SYNERGIE DATE"
echo "Tp send all files at once:  send_models.sh WRF KNEW0070 CIPS 20120101000000 SEND_ALL"
exit 1
}

anysendall() {
 if [ "${SEND_ALL}" == "SENDALL" ]; then
	SEND_ALL="SEND_ALL"
	echo "Setting SEND_ALL properly. Do not use SENDALL; use SEND_ALL"
 fi
}

loginfo() {
 echo "$*" >> $SENDMODELS_LOG
}

FR3digits() {
awk '{printf("%.3d\n",$1)}'
}

FR2DWD() {
range=$1
DAY=`echo $range | awk '{printf("%.2d\n", int($1/24) ) }'`
HOUR=`echo $range | awk '{printf("%.2d\n", int($1%24) ) }'`
echo ${DAY}${HOUR}0000
}

DWD2FR4digits() {
file=$1
DAYHOURS=`echo $file |cut -c5-6|awk '{print $1*24}'`
RESTHOURS=`echo $file |cut -c7-8`
let FR=DAYHOURS+RESTHOURS
range1=`echo $FR | awk '{ printf("%.4d\n",$1) }'`
echo $range1
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

######################################################################
#######################    MAIN     ##################################

if [ -z "$*" ]; then
	usage
fi
export NHOSTS=1
export NSLOTS=1

model=`echo $MODEL | tr "[A-Z]" "[a-z]"`
MODULE="nwp/$MODEL/$GRID/${model}_${GRID}"


#~~
anysendall

## Module load
. /etc/profile.d/modules.sh
module load taskcenter/sms
module load $MODULE
echo "Loading module $MODULE"

FILESDIR=$HOLDSPACE/$MODEL/$GRID/$DATE/out

case $TARGET in 
	FULL) 
		FRLIST=`seq 0 $OUTPUT_INTERVAL $MAX_FORECAST_RANGE | FR3digits ` ;;
	CIPS) 
		## For FTP
		HOSTLIST="192.168.1.101 192.168.1.102" ;
		USER=cips_in
		PASS=cips_in
		FTPDIR="moddb/"

		## For files
		FRLIST=`seq 0 $OUTPUT_INTERVAL 36 | FR3digits ` ; 
		FRLIST="$FRLIST `seq 39 3 $MAX_FORECAST_RANGE | FR3digits `" ;;
	SYNERGIE) 
		## For FTP
		HOSTLIST="192.168.1.15 192.168.1.16" ;
		#HOSTLIST="192.168.1.16" ;
		USER=retim2000
		PASS=retim2000
		FTPDIR="./"

		## For files
		FRLIST=`seq 0 $OUTPUT_INTERVAL 36 | FR3digits ` ; 
		FRLIST="$FRLIST `seq 39 3 96 | FR3digits `" ;
		FRLIST="$FRLIST `seq 102 6 120 | FR3digits `" ;;
	ALL)
		/share/common/bin/send_models.sh $MODEL $GRID CIPS $DATE $SENDALL  ;
		/share/common/bin/send_models.sh $MODEL $GRID SYNERGIE $DATE $SENDALL  ;;
	*) 
		echo "Type of Forecast range list unknown.. ##$RANGE_LIST_TYPE##.. Aborting" ;
		exit 1 ;;
esac 
case $MODEL in 
	COSMO) 
		if [ -z "$DEFAULT_FILENAME" ] && [ "$SEND_ALL" != "SEND_ALL" ]; then
			echo "DEFAULT_FILENAME not set.. aborting"
			exit 1
		fi
		if [ "$SEND_ALL" == "SEND_ALL" ]; then
			echo "Processing all adapted ranges";
		else
			range=`DWD2FR4digits $DEFAULT_FILENAME | FR3digits` ;
			echo "Processing range $range";
		fi
		prefix=$DEFAULT_FILENAME ;
		prefixALL="lfff"
		set +x ;
		suffix=".grb" ;;	
	HRM) 
		if [ -z "$DEFAULT_FILENAME" ] && [ "$SEND_ALL" != "SEND_ALL" ]; then
			echo "DEFAULT_FILENAME not set.. aborting"
			exit 1
		fi
		if [ "$SEND_ALL" == "SEND_ALL" ]; then
			echo "Processing all adapted ranges";
		else
			range=`DWD2FR4digits $DEFAULT_FILENAME | FR3digits` ;
			echo "Processing range $range";
		fi
		prefix=$DEFAULT_FILENAME
		prefixALL="h?ff"
		suffix="-synergie_supported.grb" ;;	
	WRF)
		range=`echo $DMT_ECHEANCE | cut -c1-4 | FR3digits`   ;
		if [ "$SEND_ALL" == "SEND_ALL" ]; then
			echo "Processing all adapted ranges";
		else
			echo "Processing range $range";
		fi
		range_fmt=$range
		prefixAN="wrfprs_d02." ;	
		prefixFR="wrfprs_d02." ;	
		prefixALL="wrfprs_d02.";
		case $range in 
			0000) prefix=${prefixAN}${range_fmt} ;;
			   *) prefix=${prefixFR}${range_fmt} ;;
		esac
	
		suffix_CIPS="-datapolicy.grb" 
		suffix_SYNERGIE="-synready.grb"

		case $TARGET in
			SYNERGIE) 
				## Set suffix to proper value
				suffix=$suffix_SYNERGIE

				#~~ 
				FILES2XFER=`ls $FILESDIR/${prefix}*${suffix_CIPS}`
				## Process files for Synergie
				for f in $FILES2XFER ; do
					nf=${f%%-*}${suffix_SYNERGIE}
					echo "Calling $WRF2SYN $f $nf"
					$WRF2SYN $f $nf	
					#rm -f $f
				done
				
				echo "Files $FILES2XFER processed for Synergie... sending to $TARGET";;
			CIPS)
				## Set suffix to proper value
				suffix=$suffix_CIPS
				echo "Proceed with $FILES2XFER... sending to $TARGET";;
		esac  ;;

	*) 
		echo "Unknown MODEL=##$MODEL##. Aborting" 
		exit 1 ;;
esac

## Files to transfer 
echo "Going to $FILESDIR"
cd $FILESDIR
FILES2XFER=`ls ${prefix}*${suffix}`

## If you want to resend all files from a run, use a fifth argument "SEND_ALL"
if [ "$SEND_ALL" == "SEND_ALL" ]; then
	FILES2XFER=""
	for range in $FRLIST ; do
		case $MODEL in 
			HRM | COSMO) 
				DATE=`FR2DWD $range`;
				FILES2XFER="$FILES2XFER `ls *${DATE}*.grb`" ;;
			WRF) 
				FILES2XFER="$FILES2XFER `ls ${prefixALL}${range}*${suffix}`";;
			*)
				echo "MODEL $MODEL UNKNOWN"; exit 1;;
		esac
	done

	## set isGrepped so that it runs
	isGrepped="SEND_ALL"
	r=0
else
	isGrepped=`echo $FRLIST | grep $range`
	r=0
fi

if [ ! -z "$isGrepped" ]; then
	echo "$FILES2XFER to be sent!"

	## For Synergie, use another extension (.GB)	
	if [ "$TARGET" == "SYNERGIE" ]; then
		GBFILES=""
		for f in $FILES2XFER; do
			nf=$f.GB
			ln -sf $f $nf
			GBFILES="$GBFILES $nf"
		done
	else	
		GBFILES=$FILES2XFER
	fi

	## Send to all ips
	for ip in $HOSTLIST; do
		echo ""
		echo "Sending $GBFILES to $ip"
		RETRIES=5
		TIME_OUT=20
		loginfo "SEND_MODELS : sending $GBFILES to $TARGET"
		loginfo  "$NCFTPPUT -S .tmp -u $USER -p $PASS $ip $FTPDIR $GBFILES"
		$NCFTPPUT -S .tmp -u $USER -p $PASS $ip $FTPDIR $GBFILES  2>&1 | tee -a $SENDMODELS_LOG
		resp=$?
		if  [ $r -ne 0 ]; then
			echo "$RETRIES retries later, connection still failed. Aborting"
			let r=r+resp 
		fi
	done
else
	echo "FILES2XFER=$FILES2XFER"
	echo "Skipped since not part of RANGE_LIST_TYPE $RANGE_LIST_TYPE!"
	echo $FRLIST
fi

####   
## Remove only Synergie dedicated files, since they can be recreated from regularfiles
#if [ "$SEND_ALL" == "SEND_ALL" ]; then
#	rm -f *${suffix_SYNERGIE}
#else
#	rm -f *${range}*${suffix_SYNERGIE}
#fi

#echo ====== ls 2 : >> /tmp/claude.log
#ls >> /tmp/claude.log
#echo TARGET=$TARGET FILES2XFER=$FILES2XFER >> /tmp/claude.log
#echo ====== ls end >> /tmp/claude.log

exit $r
