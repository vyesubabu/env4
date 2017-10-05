#!/bin/bash
#
# This script relinks the main config files of the cluster on the local node
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Oct, 04  2017     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0: 20171004						      # 
#		- init in /root/ClusterTARS				      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

ClusterTarsDir=/root/ClusterTARS

#FileList=`find . -type f|grep -v tgz` 

cd $ClusterTarsDir
latestSlurmConf=`ls -rt ./etc/slurm/slurm.conf* | tail -1` 
EXTENSION=`echo $latestSlurmConf| sed "s:.*conf::g"`
FileList=`find . -type f|grep -v tgz |grep $EXTENSION` 

NOW=`date -u +%Y%m%d%H%M`

# eg: ./etc/slurm/slurm.conf.VBOX.201710041527
echo "Processing files from $EXTENSION..."

for file in $FileList; do

	echo "Processing $file"
	basefile=`basename $file $EXTENSION` 
	dirname=`dirname $file` 
	dirname_local=`dirname $file | sed "s:^\./:/:"` 

	file2test=$dirname_local/$basefile

	if [ "$file2test" == "/etc/munge/munge.key" ]; then
		LINKER="ln"
		rm /etc/munge/munge.key
		$LINKER $ClusterTarsDir/$file $file2test
		ln -sf $ClusterTarsDir/$file /etc/munge/current_mungekey
		## fix rights
		cd /etc/munge
		chown -R munge.munge *
	else
		LINKER="ln -sf"
		if [[ -L "$file2test" ]]; then 
			echo "$file2test is already a symlink; relinking"; 
			$LINKER $ClusterTarsDir/$file $file2test; 
		else 
			echo "$file2test is not a symlink! moving!"; 
			mv $file2test $file2test.backup.$NOW; 
			$LINKER $ClusterTarsDir/$file $file2test; 
		fi
	fi


done

