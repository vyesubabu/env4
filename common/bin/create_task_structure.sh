#!/bin/bash
#
# This script creates a skeleton for a task
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.1: 20140716						      # 
#		- Add: README to each subdir (for GIT compatibility)
#	* v1.0.0: 20140310						      # 
#		- Add module copy
#		- Update to add pack & rephase launchscripts at init	      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


### Set this option to YES if you want to automatically create the structure in any given directory (even if it doesnt exist) 
#AUTOMATED_CREATION="YES"
AUTOMATED_CREATION="NO"
TODAY=`date -u +%Y%m%d`"000000"

function init_module {

	PRIVATEMODULE_HOME=$HOME/.privatemodules
	[[ -d $PRIVATEMODULE_HOME ]] || mkdir -p $PRIVATEMODULE_HOME
	
	if [ ! -f $PRIVATEMODULE_HOME/mymodule.template ]; then
		echo "copying module.template  to your $PRIVATEMODULE_HOME"
		echo "To view it:  module load use.own ; module avail"
		cp $COMMON_HOME/softwares/templates/scripts/mymodule.template $PRIVATEMODULE_HOME
	fi
}  
function create_dir_struct {

	mkdir -p $1/bin
	echo "This is directory for binaries and scripts" >> $1/bin/README
	mkdir -p $1/input
	echo "This is directory for input data" >> $1/input/README
	mkdir -p $1/out
	echo "This is directory for output data" >> $1/out/README
	mkdir -p $1/run
	echo "This is directory for processing and work dir" >> $1/run/README
	mkdir -p $1/resources
	echo "This is directory for alternative ressources" >> $1/resources/README
}  
function copy_main_files {
	cd $1
	cp $COMMON_HOME/softwares/templates/scripts/master.sh bin
	#cp $COMMON_HOME/softwares/templates/scripts/template_launch.sh ./launch.sh
	cp $COMMON_HOME/softwares/templates/scripts/launch.sh ./launch.sh
	cat $COMMON_HOME/softwares/templates/scripts/task_localtest.sh | sed "s:TODAY:$TODAY:g" > ./task_localtest.sh
	chmod +x ./task_localtest.sh
}
function tar_folder {
	cd $1
	$COMMON_HOME/bin/make_task_tar.sh FORCE
}
function rephase_scripts {
	cd $1
	$COMMON_HOME/bin/rephase_launchscripts.sh
}

dir=$1

## if no dir name is given
if [ -z "$dir" ]; then
	echo "you did not specify a directory. Please specify an existing directory"
	exit 0

else  ## if a dir name is given

  if [ -d $dir ]; then
	echo "$dir exists! Creating standardized task structure"
	create_dir_struct $dir
	copy_main_files $dir
	tar_folder $dir
	rephase_scripts $dir
	init_module 

  else  ## if the dir does not pre-exist, we ask
        if [ "$AUTOMATED_CREATION" == "YES" ]; then

	  create_dir_struct $dir
	  copy_main_files $dir
	  tar_folder $dir
	  rephase_scripts $dir
	  init_module 

	elif [ "$AUTOMATED_CREATION" == "NO" ]; then
  	  echo "$dir has not been created... Do you wish to create it? [y/n]"
	  read answer
	  if [ "$answer" == "y" ]; then
		create_dir_struct $dir
		copy_main_files $dir
		tar_folder $dir
		rephase_scripts $dir
	  	init_module 
	  else
		echo "Not creating anything!"
		exit 0
	  fi

	else
	  echo "What kind of AUTOMATED_CREATION parameter is this?? Put YES or NO please!"
	  exit 0
	fi

  fi 
fi
