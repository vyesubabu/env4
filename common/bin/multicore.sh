#!/bin/bash

action()
{
echo $1
convert $1 $1.png
sleep 3
}

current=1
#threads=$((cat /proc/cpuinfo|grep '^processor'|wc -l))
threads=`cat /proc/cpuinfo|grep '^processor'|wc -l`

while [ $# -gt 0 ]; do

	action $1 &

	#div=$((current/$threads))
	#mul=$((div*$threads))
	div=$((current/$threads))
	mul=$((div*$threads))

	echo $current $div $mul

	[[ "$mul" = "$current" ]] && wait

	current=$((current+1))

	shift

done
