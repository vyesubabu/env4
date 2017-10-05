#!/bin/bash
#
# This script verifies the good status of the various tools of the 
# Task Center
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2012     #
#                                                                             #
#   VERSION :								      #
#	* v2.0 : 20121107						      # 
#		- init version for Rocks+ (cipsschedop on external mach)      #
#	* v1.0 : 20100701						      # 
#		- init version for IMD					      #
#									      #
#   LATEST MODIFICATIONS :					  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


SSH=/usr/bin/ssh

echo "####################################################"
echo "# THIS STARTS THE DIAGNOSTICS FOR $HOSTNAME        #"
echo "####################################################"

echo "# IS SMS RUNNING on vcipsschedop? "
#ssh sms@vcipsschedop 'ps -ef | awk "{print $9}"| grep -w  sms'

echo " "
echo "# IS SGE RUNNING? "
ps -ef |grep sge

echo " "
echo "# IS SGE COMMUNICATING WITH SGE_EXECD daemons?"
netstat -an |grep 6444

echo " "
echo "HOW MANY INFINIBAND NODES DETECTED?"
ibnodes |grep -v Switch|wc -l
echo " "
echo "HOW MANY INFINIBAND SWITCHES DETECTED?"
ibnodes |grep  Switch|wc -l

dir2check_list="$COMMON_HOME $SHARE_HOME $SGE_ROOT"
echo " "
echo "######################################### "
echo " CHECKING NFS SHARES "
echo "######################################### "
for d in $dir2check_list; do

	if [ -d $d ]; then
		echo "$d exists"
	fi
done
echo ''
### Optional diagnostics if run as root from one of the two scheduler machines
USER=`whoami`
HOST=`hostname`

# Get subhosts list:
SUBHOSTS=`rocks list host |awk '{print $1}'|grep -v HOST|sed "s/://g"`


if [ "$USER" == "root" ]  && ( [ "$HOST" == "rocks" ] || [ "$HOST" == "rocks.local" ] || [ "$HOST" == "turtle.mfi.fr" ]) ; then
	echo "Print optional diagnostics? [Y/N]" 
	read answer
	if [ "$answer" == "Y" ] || [ "$answer" == "y" ] ; then
		
		## check for SGE & NFS share status
		for mach in $SUBHOSTS; do
			echo ""
			echo "#############################################################################"
			echo "STATUS ON $mach : SHOULD HAVE ALL /scratch & /share & SGEEXECD RUNNING"
			echo "#############################################################################"
			$SSH $mach ps -ef |grep sge
			echo ""
			$SSH $mach df -h |grep -v /dev
		done
		echo ""
	fi
fi
