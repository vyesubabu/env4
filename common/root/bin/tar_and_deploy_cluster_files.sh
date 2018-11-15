#!/bin/bash
#
# This script synchronizes the shared files across the cluster
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2017     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.2: 20171120						      # 
#		- Add: ecfnode03 (on compute06 of miniHPC Indo)
#	* v1.0.1: 20171005						      # 
#		- Add: ecfnode02
#	* v1.0.0: 20171004						      # 
#		- Removed slurmdbd.conf from phasing			      #
#		- Now use test_and_relink.sh on nodes			      #
#		- MASTER_TYPE changes auto between VBOX & VMWARE	      #
#		  depending on $HOSTNAME of master!
#		- ClusterTarsDir fixed to /root/ClusterTARS		      #
#		- ClusterFiles 						      #
#		- init 							      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


function dispatch_tar() {
	TAR=$1
	NODE=$2

	if [ -z "$NODE" ] || [ -z "$TAR" ]; then
		echo "Abort. Pass : dispatch_tar TAR NODE as arguments"
		exit 1
	fi

	ssh root@$NODE "[[ -d $ClusterTarsDir ]] || mkdir -p $ClusterTarsDir"
	scp $TAR root@$NODE:$ClusterTarsDir
	#return $?
}

function untar_and_relink() {
	TAR=$1
	NODE=$2

	if [ -z "$NODE" ] || [ -z "$TAR" ]; then
		echo "Abort. Pass : dispatch_tar TAR NODE as arguments"
		exit 1
	fi
	ssh root@$NODE "cd $ClusterTarsDir ; tar xvfz $TAR"
	
	# 
	echo "Launching relinking of file"
	ssh root@$NODE "/root/test_and_relink.sh"	

}

function restart_services() {
	NODE=$1

	ssh root@$NODE "systemctl restart munge"
	ssh root@$NODE "systemctl restart slurmd"

}
##################################################
#			MAIN

case $HOSTNAME in 
	ecfnode01) 
		MASTER_TYPE="VMWARE";;
	ecFlow-Central)
		MASTER_TYPE="VBOX";;
	*) 
	echo "Wrong machine to be a master! Abort!"
	exit 1
	;;
esac

#ClusterFiles="/etc/slurm/slurm.conf /etc/slurm/slurmdbd.conf /etc/hosts /etc/munge/munge.key"

## Do not send slurmdbd.conf : it belongs on master only
ClusterFiles="/etc/slurm/slurm.conf /etc/hosts /etc/munge/munge.key"

ClusterNodes="ecfnode01 ecfnode02"
ClusterNodes="ecfnode01 ecfnode02 ecfnode03"
ClusterTarsDir=/root/ClusterTARS

NOW=`date -u +%Y%m%d%H%M` 
EXTENSION=$MASTER_TYPE.$NOW

TMPDIR=/tmp/prepTar.$$

[[ -d $TMPDIR ]] ||  mkdir -p $TMPDIR

for file in $ClusterFiles; do
	dirname=`dirname $file` 
	fname=`basename $file` 
	mkdir -p $TMPDIR/$dirname

	# Dereference symlinks, keep ownership, etc..
	cp -Lrp $file $TMPDIR/$dirname
	
	mv $TMPDIR/$file $TMPDIR/$file.$EXTENSION
done

echo "Gonna tar all this:"
ls -lrt $TMPDIR 

TARFILE=ClusterFiles.$NOW.$HOSTNAME.tgz
cd $TMPDIR
tar cvfz $TARFILE *

########################################################"
#	STEP 2 : DEPLOY THE ClusterFiles to the nodes
#		a) untar 
#		b) symlink to new files
#		c) restart services
#########################################################
#exit 0
for node in $ClusterNodes; do 

	

	#~~ dispatch tar to node
	dispatch_tar $TARFILE $node	

	#~~ untar & symlink on node
	untar_and_relink $TARFILE $node

	#~~ restart services
	restart_services $node

done

sinfo -a


