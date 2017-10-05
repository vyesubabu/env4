#!/bin/bash
#
# This script crops out various ArchiPEL global satellite images 
# into animated gifs
#
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Nov, 01  2012     #
#                                                                             #
#   VERSION :								      #
#	* v1.1 : 20121105						      # 
#  		- date stamps						      #
#	* v1.0 : 20121028						      # 
#  		-init							      #
#
#   PRE-REQS: ImageMagick (convert)
#									      #
#   LATEST MODIFICATIONS :					  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

set -x 

SOURCE=$1
VAR=$2
MAX_FRAMES=$3

# Default config
if [ -z "$SOURCE" ] ; then SOURCE="goes-e" ; fi
if [ -z "$VAR" ] ; then VAR="ir107" ; fi
if [ -z "$MAX_FRAMES" ] ; then MAX_FRAMES=24 ; fi

DATADIR=/scratch/data/archipel/$SOURCE
TODAY=`date -u +%Y%m%d`
TODAYHH=`date -u +%Y%m%d%H`
#OUTFILE=$DATADIR/$TODAY/${TODAYHH}_anim_${SOURCE}_${VAR}.gif
OUTDIR=/var/www/html
OUTFILE=$OUTDIR/latest_anim_${SOURCE}_${VAR}.gif
CROPSCRIPT=/common/bin/cropGoes.sh
#MAKELABEL=/root/REMI/makelabel.sh

cd $DATADIR/$TODAY
FL=`ls globe*${VAR}* |tail -${MAX_FRAMES}`

# tmp filename based on source
case $SOURCE in
	meteosat-highrate) 
			case $VAR in
				hrvFog) tmpfile=tmp1 ;
					screen_geometry=1580x1134+0-4176 ;;
				ccgene) tmpfile=tmp1-0 ;
					screen_geometry=1580x1134+0-1500 ;;
				*) 
					echo "Unknown type of channel $VAR"; 
					exit 1;;
			esac ;;  	
	goes-e) 
			tmpfile=tmp1 ;
			screen_geometry=1580x1134+0-512 ;;
	*) 
			echo "Which source is this?? Abort!" ; 
			exit 1 ;;
esac

count=0
for f in $FL ; do

	YYYYMMDDHHmm=`echo $f | awk 'BEGIN {FS ="."} {print $3$4}'`
	OUTTMPFILE=${SOURCE}_${VAR}_$YYYYMMDDHHmm.jpg

	if [ ! -f $OUTTMPFILE ] ; then
		$CROPSCRIPT $f $screen_geometry
	fi

	mv $tmpfile.jpg $OUTTMPFILE
	
	ANIM_FL="$ANIM_FL $OUTTMPFILE"
	let count=count+1
done

convert -delay 50 -loop 0 $ANIM_FL $OUTFILE

#cleanup
#rm -f *.jpg toto.gif
rm -f toto.tif tmp*.jpg
	
