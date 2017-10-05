#!/bin/bash
#
# This script checks the dates inside WRF netcdf files
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0: 20140326						      # 
#		- Check WRF files: START_DATE & SIMULATION_DATE		      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

module load netcdf/intel/64/4.3.0

FILELIST=$1

if [ -z "$FILELIST" ]; then
	FILELIST=`ls wrf[bi]* `
fi

for f in $FILELIST; do
	echo $f
	ncdump -h $f | grep DATE
	echo
done

