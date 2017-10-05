#!/bin/bash
#
# This script makes a label image (label.jpg) with argument $2 as text
# that can further be composited into an image given as $1
#
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Nov, 01  2012     #
#                                                                             #
#   VERSION :								      #
#	* v1.1 : 20121107						      # 
#  		- add creation tag on southeast corner
#	* v1.0 : 20121028						      # 
#  		-init, label string in northwest corner			      #
#
#   PRE-REQS: ImageMagick (convert)
#									      #
#   LATEST MODIFICATIONS :					  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  makelabel.sh myframe.jpg "Today 8h30"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

set -x

echo "Working in $PWD"
frame=$1
labelfile=label.jpg
string=$2
outfile=$frame.new.jpg
tagfile=tagfile.jpg

export TZ=Europe/Paris

if [ -z "$frame" ]; then
	echo "Usage: $0 framefile.jpg"
	exit 1
fi
# Default text : current date+hour of processing
HHMM=`date +%H%M`
DATE=`date +"%Y/%m/%d %Hh%M"`
if [ -z "$string" ]; then
	string=$DATE
fi

echo "Making label image with string : $string"

# Create label file
convert -background lightblue -fill blue -pointsize 72 label:"$string"  $labelfile 

# Create "processed on $DATE" tagfile
convert -background black -fill white -pointsize 20 label:"Processed on $DATE local time"  $tagfile 

## on realise le compositage des deux images!
composite -dissolve 100 $labelfile -gravity northwest  $frame  tmpframe.$$.jpg
#$outfile
composite -dissolve 100 $tagfile -gravity southeast tmpframe.$$.jpg $outfile


rm -f $tagfile tmpframe.$$
