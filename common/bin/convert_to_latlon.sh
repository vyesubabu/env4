#!/bin/bash
#
# This script converts the rotated lat-lon grid from COSMO to non rotated
# (fine it was not really rotated to begin with...) 
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTEUR: REMI MONTROTY                                   Aug, 28  2011     #
#                                                                             #
#                                                                             #
#   Exemple:                                                                  #
#                                                                             #
#        ./convert_to_latlon.sh  lfff01000000 lfff01000000.grb                #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
CDO=/share/common/bin/cdo
INPUTFILE=$1
OUTPUTFILE=$2

if [ -z "$INPUTFILE" ]; then 
	echo "Missing input file. Usage is $0 INPUTFILE OUTPUTFILE"
	exit 2
fi
if [ -z "$OUTPUTFILE" ]; then 
	OUTPUTFILE=result.grb
fi

## Get a grid description & remove any pole description
$CDO griddes $INPUTFILE | grep -v pole > mynewgrid.def

## Convert to the new grid
$CDO setgrid,mynewgrid.def $INPUTFILE $OUTPUTFILE








