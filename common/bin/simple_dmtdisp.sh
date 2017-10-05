#!/bin/bash
#
# This script prepares the environment for sending a simple advisory,
# through dmtdisp, with notification of events coming from incrond
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Dec, 04  2012     #
#                                                                             #
#   VERSION :								      #
#	* v1.1 : 20121206						      # 
#		-add "subsystem" as -s option
#	* v1.0 : 20121204						      # 
#		-Init script for Djibouti image & Kenya WRF		      #
#									      #
#   Pre-Requisites :						  	      #
#                       
#	dmtdisp-1.0-static.x86_64.rpm   		                      #
#
#   Example:                                                                  #
#                                                                             #
# ./simple_dmtdisp.sh -a METEOSAT9_SPACE_00E_HRVCLOUD -t cipsschedop \
#  -s imgdb -d 20121204080000
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

. $HOME/.bash_profile
. /etc/profile.d/modules.sh
module load taskcenter/common.svn

#-----------------------------------------------------------------
 print_usage() {
#-----------------------------------------------------------------
  echo "$0 usage"
  echo "    -a   	ADVISORY"
  echo "    -d   	DATE"
  echo "    -s   	SUBSYSTEM"
  echo "    -t  	TARGET"
  echo "    -v 		verbose"
  exit 1
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
  export DMT_SOUS_SYSTEME=$SUBSYSTEM
  export DMT_SERVER_HOST=$TARGET
  
  loginfo SEND_ADVISORY $ADVISORY $DATE
  echo "dmtdisp ${ADVISORY} 0 $DATE" >> $LOGFILE
  dmtdisp ${ADVISORY} 0 $DATE
}

################################################################"
#  			MAIN
################################################################
# ex: PGFSUS_GLOB0500_COMPLETED_007200 0 20110525000000
#  STAGE=COMPLETED STAGE=UNGRIBBED STAGE=METGRIDDED

# PWRF_KNEW0062_RECEIVED_12
# METEOSAT9_SPACE_00E_HRVCLOUD


while getopts a:d:s:t:v: opt
 do
      case $opt in
          a) ADVISORY="$OPTARG" ;;
          d) DATE="$OPTARG";;
          s) SUBSYSTEM="$OPTARG";;
          t) TARGET="$OPTARG"  ;;
          v)  	if [[ $OPTARG = -* ]]; then
        		((OPTIND--))
        		continue
      		fi
	 	verbose="TRUE"; 
		set -x;;
          x) X="$OPTARG";;
          ?) print_usage $0
             exit 1;;
      esac
done


## Set default vars
if [ -z "$ADVISORY" ]; then
	loginfo "No Advisory!"
	print_usage $0
fi 
if [ -z "$LOGFILE" ]; then
	LOGFILE=/tmp/${0##*/}.log
fi 
if [ -z "$DATE"  ]; then
	loginfo "DATE NOT SET !? ABORTING..."
	exit 1
fi 
if [ -z "$TARGET"  ]; then
	loginfo "TARGET NOT SET "
	loginfo "Setting TARGET=cipsschedop as default"
	TARGET="cipsschedop"
fi 
if [ -z "$SUBSYSTEM"  ]; then
	loginfo "SUBSYSTEM NOT SET !? ABORTING..."
	exit 1
fi 
#~~
send_signal	

if [ "$verbose" == "TRUE" ]; then
	echo "ADVISORY:             "$ADVISORY
	echo "DATE:	            "$DATE
	echo "SUBSYSTEM:	    "$SUBSYSTEM
	echo "TARGET:               "$TARGET
	echo "Verbose:              "$verbose
fi 
