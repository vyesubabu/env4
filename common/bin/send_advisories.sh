#!/bin/bash
#
# This script sends a Data Advisory for a specific date, a specific Forecast
# Range and a specific stage of the data
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2011     #
#                                                                             #
#   VERSION :								      #
#	* v3.3b2-rev2:  20170426					      # 
#		- Add: use DMT_SERVER_HOST if existing
#	* v3.3b2-rev1:  20170404					      # 
#		- Add: FRFINAL and 1,2,3,4 or 6 digits for FR
#		- Add: FR=$RANGE if RANGE is digits
#	* v3.3.0-rev1:  20151217					      # 
#		- Add: DMT_DATE_VALID as DATESEND if set in environment
#		useful for LRFDB
#	* v3.2b3-rev2:  20141016					      # 
#		- Add: Handle SMSNODE_LIST if it exists to send the signal to
#		all necessary SMSNODES (CSIJAN, VSCHEDOP)
#	* v3.2.0-rev1:  2014922						      # 
#		- Add: option date as -d
#	* v1.2:  20131009						      # 
#		- Revisited for HPC BMKG
#	* v1.1:  20121129						      # 
#		- Revisited for miniHPC + incrontab 		     	      #
#	* v1.0:  20110111						      # 
#		- Sends an advisory & returns loginfo to $LOGFILE     	      #
#		- Sends to rocks.mfi.fr since IP & vcipssched not shared 
#			on computes 			     	      	      #
#									      #
#   LATEST MODIFICATIONS :					              #  
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  send_advisories.sh -m $COUPLING_MODEL -g $COUPLING_GRID -r $DMT_ECHEANCE \
#   -s UNGRIB -f somefile -l $LOGFILE
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#--------init ENV-----------
. /etc/profile.d/modules.sh
export MODULEPATH=/cm/shared/modulefiles:$MODULEPATH
#module load taskcenter/sms
#module load taskcenter/smslib
module load taskcenter/sms_advisories

#-----------------------------------------------------------------
 print_usage() {
#-----------------------------------------------------------------
  echo "  Namelist editor"
  echo "    -d   	DMT_DATE_PIVOT (YYYYMMDDHHMMSS)"
  echo "    -m   	MODEL"
  echo "    -g   	GRID"
  echo "    -r  	RANGE"
  echo "    -f  	FILENAME"
  echo "    -s		STAGE"
  echo "    -l		LOGFILE"
  echo "    -v 		verbose"
}
if [ -z "$*" ]; then 
	print_usage $0
fi

#-----------------------------------------------------------------
  loginfo() {
#-----------------------------------------------------------------
  echo `date -u`" : "$* >> $LOGFILE
}

#-----------------------------------------------------------------
  send_signal() {
#-----------------------------------------------------------------
  export DMT_SOUS_SYSTEME=fromHPC

  if [ ! -z "$DMT_SERVER_HOST" ]; then
	echo "Using DMT_SERVER_HOST=$DMT_SERVER_HOST as passed by environment"
  elif [ ! -z "$SMSNODE" ]; then
	export DMT_SERVER_HOST=$SMSNODE
  else
	export DMT_SERVER_HOST=CSIJAN.nc.bmkg.local
  fi
	
  
set +x
# ex: PGFSUS_GLOB0500_COMPLETED_007200 0 20110525000000
#  STAGE=COMPLETED STAGE=UNGRIBBED STAGE=METGRIDDED


## In case we need to send LRF COMPLETE later than the same day
if [ ! -z "$DMT_DATE_VALID" ]; then
	DATE_SEND=$DMT_DATE_VALID
else
	DATE_SEND=$DMT_DATE_PIVOT
fi


# Define the forecast range
  case $FR in
    [0-9]) 
        FRFINAL=000${FR}00;;
    [0-9][0-9]) 
        FRFINAL=00${FR}00;;
    [0-9][0-9][0-9]) 
        FRFINAL=0${FR}00;;
    [0-9][0-9][0-9][0-9]) 
        FRFINAL=${FR}00;;
    [0-9][0-9][0-9][0-9][0-9][0-9]) 
        FRFINAL=$FR;;
    *) 
        echo "ERROR : Only accepting 1,2,3,4 or 6 digits for FR=$FR passed by -r option"
        exit 1
    ;;
  esac
  ressource=${MODEL}_${GRID}_${STAGE}_${FRFINAL}

  loginfo SEND_ADVISORY $FILENAME $ressource $FR
  echo "Sending advisory to $DMT_SERVER_HOST"
  echo "dmtdisp ${ressource} 0 $DATE_SEND "
  echo dmtdisp ${ressource} 0 $DATE_SEND >> $LOGFILE
  dmtdisp ${ressource} 0 $DATE_SEND
}

################################################################"
#  			MAIN
################################################################

while getopts m:g:l:r:f:s:v:d: opt
 do
      case $opt in
          d) DMT_DATE_PIVOT="$OPTARG" ;;
          f) FILENAME="$OPTARG" ;;
          g) GRID="$OPTARG";;
          l) LOGFILE="$OPTARG"  ;;
          m) MODEL="$OPTARG";;
          r) RANGE="${OPTARG}";;
          s) STAGE="$OPTARG";;
          v)  	if [[ $OPTARG = -* ]]; then
        		((OPTIND--))
        		continue
      		fi
	 	verbose="TRUE" 
		set -x
		;;
          x) X="$OPTARG";;
          ?) print_usage $0
             exit 1;;
      esac
done

#set -x

## Set default vars
if [ "$LOGFILE" == "" ]; then
	LOGFILE=/tmp/${0##*/}.log.$$
fi 
if [ "$FILENAME" == "" ]; then
	loginfo ADVISORY WITHOUT FILENAME
fi 

if [ "$RANGE" == "" ]; then
	print_usage $0
	exit 1
fi
if [ "$DMT_DATE_PIVOT" == "" ]; then
	loginfo "DMT_DATE_PIVOT NOT SET !? ABORTING..."
	echo "DMT_DATE_PIVOT NOT SET !? ABORTING..."
	exit 1
fi 

#Get FR
if [[ ${#RANGE} -lt 6 ]]; then
	FR=`echo $RANGE | cut -c1-4 | awk '{print $1/1.0}'`
elif [[ ${#RANGE} -eq 6 ]]; then
	FR=$RANGE
else
	echo "What is this RANGE=$RANGE?"
	exit 1	
fi
if [ -z "$MODEL" ] ||  [ -z "$GRID" ] || [ -z "$STAGE" ] ; then
	echo "Key variables missing in $0"
	verbose="TRUE"
else
	if [ ! -z "$SMSNODE_LIST" ]; then
		for SMSNODE in $SMSNODE_LIST; do
			export SMSNODE=$SMSNODE
			send_signal	
		done
	else
		send_signal
	fi
fi

if [ "$verbose" == "TRUE" ]; then
	echo "MODEL:                "$MODEL
	echo "GRID:	            "$GRID
	echo "RANGE:                "$RANGE
	echo "FILENAME:             "$FILENAME
	echo "LOGFILE:             "$LOGFILE
	echo "STAGE:   		    "$STAGE
	echo "Verbose:              "$verbose
fi 

