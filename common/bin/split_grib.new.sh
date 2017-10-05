#!/bin/bash
#set -x
tmpFile=/tmp/split_grib.$$
gribFile=$1

if [ $# -lt 1 ] ; then
   echo "usage: $0 gribFile"
   exit 1
fi

echo -n `date`
echo " ==== Parsing $gribFile ===="
wgrib $gribFile > $tmpFile

for ech in `cat $tmpFile | cut -d':' -f9,10 | sort | uniq`
do
  P1=`echo $ech | sed 's/P1=//' | cut -d':' -f1`
  P2=`echo $ech | sed 's/P2=//' | cut -d':' -f2`
  echo -n `date`

  if [ "$P1" -lt "$P2" ]; then
    RANGE=$P2
  else
    RANGE=$P1
  fi

  echo " ==== Extracting forecast range $RANGE ( ${P1}.${P2} ) ===="
  grep -w "$ech" $tmpFile | wgrib -i -grib $gribFile -o ${gribFile}.${P1}.${P2} >/dev/null

  cat ${gribFile}.${P1}.${P2} >> ${gribFile}.${RANGE}
  rm ${gribFile}.${P1}.${P2}
done

rm $tmpFile
exit 0
