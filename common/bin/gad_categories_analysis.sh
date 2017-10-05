#!/bin/bash
WORKDIR=/shared/journal/sms/gad/tous
date=$1

if [ -z "$date" ] || [ ${#date} -ne 8 ]; then 
	echo "Wrong format for date : please provide YYYYMMDD as argument"
	exit 1
fi
cd $WORKDIR
categ=`grep nom_ress $date|sed "s:.*nom_ress=\(.....\).*:\1:"|sort -u |sort -n ` ; 
echo $categ

#exit 1
for cat in $categ; do 
	echo $cat; 
	grep "nom_ress=$cat" $date|wc -l ; 
	echo ""; 	
done
