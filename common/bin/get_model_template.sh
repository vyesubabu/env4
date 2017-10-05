#!/bin/bash

grbfile_input=$1
grbfile=$grbfile_input.record1.grb

## Select only first record for fetching template
wgrib $grbfile_input | awk '{if ($1 == 1) print $0}' FS=':' | wgrib -s $grbfile_input -i -grib -o $grbfile

## Pre-emptive clean-up
rm -f $grbfile.template

## Dump headers and data 
grib_dump $grbfile > $grbfile.dump

## Remove comments, select only the header part and format 
## according to write_grib required format 
cat  $grbfile.dump | sed -n '/editionNumber/,/typeOfPacking/p' |grep -v "#"| sed -e  "s/ = /:/g" -e "s/;$//g" | sort -n | sort -u > $grbfile_input.template

## clean-up
rm -f $grbfile.dump $grbfile
