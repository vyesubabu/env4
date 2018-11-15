#!/bin/bash
#
# This script does stuff
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2017     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0: 20170101						      # 
#		-							      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

MODULES_SRCDIR=/ecfshared/v4.0/SRC/modules-tcl-1.923
LOCALDIR=/ecflocal/v4.0/apps/EnvironmentModules/1.923/

TMPDIR=/tmp/modules.install.$$

[[ -d $LOCALDIR ]] || mkdir -p $LOCALDIR
[[ -d $TMPDIR ]] || mkdir -p $TMPDIR


cp -r $MODULES_SRCDIR/* $TMPDIR

cd $TMPDIR
make clean
./configure --prefix=$LOCALDIR

make 
make install
echo $?

##Linking 
cd /etc/profile.d
ln -sf $LOCALDIR/init/profile*sh .

## Add the ecfshared module
cp -f $MODULES_SRCDIR/ecfshared.module $LOCALDIR/modulefiles/ecfshared

## Add automatic loading to .bashrc 
echo ". /etc/profile.d/profile.sh" >> ~/.bashrc 
# reload 
. ~/.bashrc 

module avail
