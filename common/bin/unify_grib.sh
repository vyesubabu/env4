#!/bin/bash

file=YFMS20QEIA130000.20101213102311_12748612_F.LT.bin
fileout=MYCROP.grb

file=$1
fileout=$2

if [ -z "$file" ] || [ -z "$fileout" ]; then
	echo "Syntax should be: $0 filein fileout"
	exit 1
fi

### DO NOT EDIT 
WGRIB=/common/bin/wgrib
PARAM_LIST=$file.prm
RECORDS2EXTRACT=records2extract.txt


rm -f $RECORDS2EXTRACT
## list all parameters + grid info explicitly, remove first 2 fields (rec # and size)
## to obtain a list of all parameters + grid
$WGRIB $file -GDS > $PARAM_LIST

## find the unique parameters :  remove first 2 fields (rec # and size)
## to obtain a list of all parameters + grid, and sort for unique occurences
## =====> to remove duplicates
cat $PARAM_LIST | sed "s/\([0-Z]*\):\([0-Z]*\):\(.*\)/\3/" |sort -u > unique

## loop line by line 
fileunique=unique
   
exec<$fileunique
value=0

## grep only the first occurence matching the unique field
while read line
do
cat $PARAM_LIST |grep  "$line" |head -1 >> $RECORDS2EXTRACT
done

##  Extract unique parameters as a separate grib file
cat $RECORDS2EXTRACT |wgrib -i $file -o $fileout -grib

## cleanup
rm -f $RECORDS2EXTRACT unique $PARAM_LIST

