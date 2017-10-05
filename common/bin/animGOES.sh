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
#	* v1.3 : 20121122						      # 
#  		- specify domain in $4 to animate cropped geotiff
#  		- add: processDomain function
#	* v1.2 : 20121122						      # 
#  		- Use "detectblack.sh" to avoid black frames
#  		- add fy2e satellite (for Indo)
#  		- add meteosat-hri satellite (for Indian Ocean)
#	* v1.1 : 20121105						      # 
#  		- date stamps, 5x last image motion freeze		      #
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
#  animGOES.sh meteosat-hri cc
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function processGlobe() {
# tmp filename based on source
case $SOURCE in
	meteosat-highrate) 
			case $VAR in
				hrvCloud) tmpfile=tmp1 ;
					screen_geometry=1580x1134+0-1024 ;;
				hrvFog) tmpfile=tmp1 ;
					screen_geometry=1580x1134+0-4176 ;;
				ccgene) tmpfile=tmp1-0 ;
					screen_geometry=1580x1134+0-1500 ;;
				*) 
					echo "Unknown type of channel $VAR"; 
					exit 1;;
			esac ;;  	
	fy2e) 
			tmpfile=tmp1 ;
			#screen_geometry=1580x1134+0-512 ;;
			screen_geometry=1580x1134+0+0;;
	goes-e) 
			tmpfile=tmp1 ;
			screen_geometry=1580x1134+0-512 ;;
	meteosat-hri) 
			tmpfile=tmp1 ;
			screen_geometry=1580x1134+0+512 ;;
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

	## use MAKELABEL script to add date in NorthWest corner
	echo "$MAKELABEL $tmpfile.jpg $YYYYMMDDHHmm"
	$MAKELABEL $tmpfile.jpg $YYYYMMDDHHmm
	if [ $? -ne 0 ]; then
		echo "error in processing of $tmpfile to get $OUTTMPFILE"
		exit 1
	fi
	mv $tmpfile.jpg.new.jpg $OUTTMPFILE
#	mv $tmpfile.jpg $OUTTMPFILE
	
	ANIM_FL="$ANIM_FL $OUTTMPFILE"
	let count=count+1
done

# Add 5 times last image to freeze motion
for i in `seq 1 5`; do
	LAST5="$LAST5 $OUTTMPFILE"
done

ANIM_FL="$ANIM_FL $LAST5"

}
function processDomain() {

ANIM_FL=""
for f in $FL; do	
	YYYYMMDDHHmm=`echo $f | awk 'BEGIN {FS ="."} {print $3$4}'`
	OUTTMPFILE=${DOMAIN}_${SOURCE}_${VAR}_$YYYYMMDDHHmm.jpg

	if [ ! -f $OUTTMPFILE ] ; then
		convert $f $f.jpg
		## use MAKELABEL script to add date in NorthWest corner
		echo "$MAKELABEL $f.jpg $YYYYMMDDHHmm"
		$MAKELABEL $f.jpg $YYYYMMDDHHmm
		if [ $? -ne 0 ]; then
			echo "error in processing of $tmpfile to get $OUTTMPFILE"
			exit 1
		fi
		mv $f.jpg.new.jpg $OUTTMPFILE		
	fi

	ANIM_FL="$ANIM_FL $OUTTMPFILE"
done

# Add 5 times last image to freeze motion
for i in `seq 1 5`; do
	LAST5="$LAST5 $OUTTMPFILE"
done

ANIM_FL="$ANIM_FL $LAST5"

}


#### START MAIN
set -x 

SOURCE=$1
VAR=$2
MAX_FRAMES=$3
DOMAIN=$4

# Default config
if [ -z "$SOURCE" ] ; then SOURCE="goes-e" ; fi
if [ -z "$VAR" ] ; then VAR="ir107" ; fi
if [ -z "$MAX_FRAMES" ] ; then MAX_FRAMES=24 ; fi
if [ -z "$DOMAIN" ] ; then DOMAIN="globe" ; fi

DATADIR=/scratch/data/archipel/$SOURCE
TODAY=`date -u +%Y%m%d`
TODAYHH=`date -u +%Y%m%d%H`
#OUTFILE=$DATADIR/$TODAY/${TODAYHH}_anim_${SOURCE}_${VAR}.gif
OUTDIR=/var/www/html
OUTFILE=$OUTDIR/latest_anim_${SOURCE}_${VAR}.gif
OUTFILE=$OUTDIR/latest_anim_${SOURCE}_${VAR}_$DOMAIN.gif
CROPSCRIPT=/common/bin/cropGoes.sh
MAKELABEL=/common/bin/makelabel.sh
DETECTBLACK=/common/bin/detectblack.sh

cd $DATADIR/$TODAY
FL=`ls ${DOMAIN}*${VAR}*.*tif* |tail -${MAX_FRAMES}`

case $DOMAIN in
	globe)
		processGlobe ;;
	*)

		processDomain ;;
esac

# detect & remove black images from animation
ANIM_NONBLACK=`$DETECTBLACK $ANIM_FL`

convert -delay 50 -loop 0 $ANIM_NONBLACK $OUTFILE

#cleanup
#rm -f *.jpg toto.gif
rm -f toto.tif tmp*.jpg label.jpg  *.geotiff.jpg
	
