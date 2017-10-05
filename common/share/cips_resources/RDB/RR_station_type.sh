#!/bin/bash
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTEUR: REMI MONTROTY                                   Jan, 01  2010     #
#                                                                             #
#                                                                             #
#   Exemple:                                                                  #
#                                                                             #
#                                          #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
## The rdb format has different accumulation types
#
#  From record $55 to $58 from rdb, we can have 1h, 3h, 6h, 12h or 24h accumulation
#
#  The purpose of this script is to have a diagnostic report on which reports are provided by which stations.
#  Encoding is done through an Accumulation Record (AR).
#  AR is incremented based on the available reports at a station. 
#  If the 1h acc report is present : AR = AR + 1 
#  If the 3h acc report is present : AR = AR + 10
#  If the 6h acc report is present : AR = AR + 100 
#  If the 12h acc report is present : AR = AR + 1000 
#  If the 24h acc report is present : AR = AR + 10000 

## to avoid problems with commas..
unset LANG

file=$1

if [ -z "$file" ]; then
  file=20100531000000.1440.SYNOP.nzdwu.rdb
fi

## in the file, get only the stations which are reporting rain on 1h, 3h, 6h, 12h or 24h accumulation

# if we *DO NOT* want the non reporting stations...
#cat $file | awk '{print $14" "$12/100" "$13/100" "$55" "$56" "$57" "$58" "$59}'| grep -v  ".* -1 -1 -1 -1 -1"| awk '
# if we *DO* want the non reporting stations...
cat $file | grep -v "^#" | awk '{print $14" "$12/100" "$13/100" "$55" "$56" "$57" "$58" "$59" 200"$17$18$19"_"$20}' | awk '
 { ar=0; if ($4 != -1 ) {ar=ar+1}
if ($5 != -1) {ar=ar+10}
if ($6 != -1) {ar=ar+100}
 if ($7  != -1) {ar=ar+1000}
 if ($8  != -1) {ar=ar+10000}
print $1" "$2" "$3" "ar" "$9
}
' > tmp 
#print $1" "ar
#print $1" "$2" "$3" "ar


echo "#  If the 1h acc report is present : AR = AR + 1; record 55"
echo "#  If the 3h acc report is present : AR = AR + 10; record 56"
echo "#  If the 6h acc report is present : AR = AR + 100; record 57" 
echo "#  If the 12h acc report is present : AR = AR + 1000; record 58" 
echo "#  If the 24h acc report is present : AR = AR + 10000; record 59 "
cat tmp| awk '{print $4}' | histo auto 2000 nb | awk '{if ($2 != 0 ) {print $0} }'


cat tmp |sort -k1 > stations_ordered.txt

rm tmp
