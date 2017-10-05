#!/bin/bash

echo "####################################################"
echo "# THIS STARTS THE DIAGNOSTICS FOR $HOSTNAME        #"
echo "####################################################"

echo "# IS SMS RUNNING? "
ps -ef |grep sms

echo " "
echo "# IS SGE RUNNING? "
ps -ef |grep sge

echo " "
echo "# IS SGE COMMUNICATING WITH SGE_EXECD daemons?"
netstat -an |grep 6444

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
if [ "$USER" == "root" ]  && ( [ "$HOST" == "rocks" ] || [ "$HOST" == "rocks.local" ] ) ; then
	echo "Print optional diagnostics? [Y/N]" 
	read answer
	if [ "$answer" == "Y" ] || [ "$answer" == "y" ] ; then
		
		## check for SGE & NFS share status
		for mach in cipsproc1 cipsproc2 cipsproc3 cipsinteg; do
			echo ""
			echo "#############################################################################"
			echo "STATUS ON $mach : SHOULD HAVE ALL 4 NFS SHARES & SGEEXECD RUNNING"
			echo "#############################################################################"
			ssh $mach ps -ef |grep sge
			echo ""
			ssh $mach df -h |grep -v /dev
		done
		echo ""
		## check for NFS share status
		for mach in cipsdev1 cipsdev2; do
			echo ""
			echo "#############################################################################"
			echo "STATUS ON $mach : SHOULD HAVE /common NFS SHARE"
			echo "#############################################################################"
			ssh $mach df -h |grep -v /dev
		done
	fi
fi
