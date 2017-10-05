#!/bin/bash
#
# This script gets the geostationary image from the day & crops it
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTEUR: REMI MONTROTY                                   Oct, 28  2012     #
#                                                                             #
#   VERSION : 1.0   / 20121028
#	- modifs : updated for GOES + MSG images from ArchiPEL
#		
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#                                          #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
set -x 
file=$1
screen_geometry=$2

if [ -z "$file" ]; then
	echo "Please provide a file to run on!"
	echo "$0 filepath/file screen_geometry"
	exit 1
fi

if [ -z "$screen_geometry" ]; then
	#screen_geometry="900x1280" ## doit etre rentree à l'envers, Hauteur x Largeur en pixels
	#screen_geometry="1200x3200"
	#screen_geometry="1050x3360"
	screen_geometry="1580x1134"
	hgt_crop=`echo ${screen_geometry##*x}`
	wdt_crop=`echo ${screen_geometry%%x*}`
	goes_crop=${wdt_crop}x${hgt_crop}
	horizontal_offset=+0
	let vertical_offset=-hgt_crop/2+50
	screen_geometry=${goes_crop}${horizontal_offset}${vertical_offset}
fi

echo "Resampling for $screen_geometry screen geometry"

convert $file toto.tif

convert -gravity center -crop ${screen_geometry} toto.tif tmp1.jpg

