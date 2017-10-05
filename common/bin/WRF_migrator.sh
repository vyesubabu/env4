#!/bin/bash
#
# This script pbzips WRF outputs , rsyncs it, deletes the older files 
# from /scratch
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jul, 01  2013     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.1 : 20130717						      # 
#		- add GRIB + WRFPRS to RSYNC
#		- change to NMIN minutes instead of days
#		- 12h for compressing, 15h for removing
#	* v1.0 : 20130701						      # 
#		- add logs, wrfinput + wrfbdy, namelist as files to RSYNC
#		- renamed to WRF_migrator.sh				      #
#		- init 							      #
#									      #
#   LATEST MODIFICATIONS :					  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

PBZIP2=/common/SVN/common/bin/pbzip2

NMIN_LIST=720
NMIN_REMOVE=900
NDAYS_LIST=0
NDAYS_REMOVE=1

####################################################
# PART 1 : FIND & COMPRESS
####################################################
WEXDIR=/scratch/WEX

cd $WEXDIR

echo "Finding uncompressed WRF files..."
## Find uncompressed WRF files & compress them
#FL=`find . -name 'wrf[bio]*' -mtime +${NDAYS_LIST} | grep -v bz2`
FL=`find . -name 'wrf[bio]*' -mmin +${NMIN_LIST} | grep -v bz2`

for f in $FL; do

	echo "Timing parallel bzip2 of $f"
	time $PBZIP2 ./"$f"

done


####################################################
# PART 2 : RSYNC
####################################################

cd $WEXDIR

FL_TO_RSYNC=files2rsync.txt
echo "Starting to fetch files to RSYNC!"
find . -name 'wrfout*.bz2' -mmin +${NMIN_LIST} > $FL_TO_RSYNC
find . -name 'rsl.*' -mmin +${NMIN_LIST} >> $FL_TO_RSYNC
find . -name 'wrf[bi]*' -mmin +${NMIN_LIST} >> $FL_TO_RSYNC
find . -name 'namelist.input' -mmin +${NMIN_LIST} >> $FL_TO_RSYNC
find . -name '*.kmz' -mmin +${NMIN_LIST} >> $FL_TO_RSYNC
find . -name '*.mf' -mmin +${NMIN_LIST} >> $FL_TO_RSYNC
find . -name '*.grb' -mmin +${NMIN_LIST} >> $FL_TO_RSYNC
find . -name 'WRFPRS*' -mmin +${NMIN_LIST} >> $FL_TO_RSYNC

## launch rsync to move to NAS
echo "RSYNC'ing.."
./rsync_over_ssh_NAS_ASSIM.sh $FL_TO_RSYNC

#exit 0
####################################################
# PART 3 : CLEAN-UP SCRATCH
####################################################
## Delete files from /scratch

echo "Finding files older than $NMIN_REMOVE mins.."
FL_TO_DELETE=`find . -mmin +${NMIN_REMOVE} | grep -v ".sh$"`

echo "Removing files "
echo $FL_TO_DELETE |xargs rm -rf 
#echo $FL_TO_DELETE

## cleanup
#rm -f $FL_TO_RSYNC
