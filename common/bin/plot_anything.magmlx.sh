#!/bin/bash
#
# This script does stuff
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0: 20141030						      # 
#		- autodiagnose min-max-spread				      #
#		- autodiagnose domain
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function get_interval() {
	fileanalysis=$1
	INTERVALS=10
	## Figure out min max of field
	MIN=`wgrib -V $fileanalysis|grep min| awk '{print $3}'`
	MAX=`wgrib -V $fileanalysis|grep min| awk '{print $4}'`
	SPREAD=`echo $MAX $MIN | awk '{print $1-$2}'`
	INTERVAL_VALUE=`echo $SPREAD  | awk '{print $1/'$INTERVALS'}'`

	echo "Plotting between $MIN and $MAX, by $INTERVALS intervals of $INTERVAL_VALUE"

}


function get_domain() {
	fileanalysis=$1
	## figure out domain
	NORTH=`wgrib -V $fileanalysis |grep lat|awk '{print $3}'`
	SOUTH=`wgrib -V $fileanalysis |grep lat|awk '{print $5}'`
	EAST=`wgrib -V $fileanalysis |grep long|awk '{print $2}'`
	WEST=`wgrib -V $fileanalysis |grep long|awk '{print $4}'`


	echo "Comparing south $SOUTH and north $NORTH..."
	if (( $(echo "$SOUTH $NORTH" | awk '{print ($1 > $2)}') )); then
		echo "South and north inverted.. Reinverting"
		NORTH_N=$SOUTH
		SOUTH_N=$NORTH

		NORTH=$NORTH_N
		SOUTH=$SOUTH_N
	fi

	echo "Plotting between S/W/N/E corners: $SOUTH, $WEST, $NORTH, $EAST"

}

module load magics/gcc/2.18.15


FILE2PLOT=$1

MAGML=/common/softwares/templates/magics/example_to_tune.magml

if [ -z "$FILE2PLOT" ] || [ ! -f $FILE2PLOT ]; then
	echo "Missing file to plot $FILE2PLOT or doesnt exist. Check"
	exit 1
fi

NRECORDS=`wgrib -v $FILE2PLOT | wc -l`

if [ $NRECORDS -gt 1 ] ; then
	echo "Multiple record file $FILE2PLOT"
	echo "Extracting one grib for analysis"
	/common/bin/extract_one_grib.sh $FILE2PLOT
	FILE2ANALYSE=$FILE2PLOT.one.grb
	
else
	echo "Single record file"
	FILE2ANALYSE=$FILE2PLOT

fi


echo "analysizing $FILE2ANALYSE"
#~ 
get_domain $FILE2ANALYSE
get_interval $FILE2ANALYSE


FILE=$FILE2PLOT

rm -f preview.*

TMP_MAGML=/tmp/run.magml

cat $MAGML | sed -e "s:__FILE__:$FILE:g"  -e "s:__INTERVAL__:$INTERVAL_VALUE:g"  \
 -e "s:__NORTH__:$NORTH:g"  -e "s:__SOUTH__:$SOUTH:g"  \
 -e "s:__EAST__:$EAST:g"  -e "s:__WEST__:$WEST:g"    > $TMP_MAGML

magmlx $TMP_MAGML

convert -rotate 90 -resize 1600x1200 preview.ps $FILE.jpg


# 
rm -f preview.ps $TMP_MAGML


eog $FILE.jpg


