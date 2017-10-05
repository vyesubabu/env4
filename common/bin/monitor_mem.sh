#!/bin/sh
mkdir -p /root/memlog
log_path=/root/memlog
dateofday="$(date +%F)"
function getmem()
{
	echo "------------------------------------------------------------------------------------------" >> "$log_path/$1-$dateofday"
	date +"%F %R:%S">> "$log_path/$1-$dateofday"
	echo "--TOP--">> "$log_path/$1-$dateofday"
	ssh -o ConnectTimeout=10 $1 top -b -n 1 -a | head -20>> "$log_path/$1-$dateofday"
	echo "--FREE--">> "$log_path/$1-$dateofday"
	ssh -o ConnectTimeout=10 $1 free>> "$log_path/$1-$dateofday"
	echo "------------------------------------------------------------------------------------------">> "$log_path/$1-$dateofday"
}
for i in $(seq -s " " -f %02g 1 32)
do

	getmem compute$i
done
