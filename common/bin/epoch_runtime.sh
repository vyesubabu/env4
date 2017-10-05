#!/bin/bash
set +x

date  +"%m/%d/%Y %H:%M:%S"
current=`date +%s`
runningjobs=`/gridware/sge/bin/lx24-amd64/qstat -u sms|awk '{ if ($5 == "r") {print $1"_"$6"@"$7}}'`


for r in $runningjobs; do
	jobid=`echo ${r%%_*}` 
	timer=`echo ${r##*_}`
	day=`echo ${timer%%@*}` 
	hour=`echo ${timer##*@}` 
	
	runningsince=`date -d "$day $hour" +%s`
	let usertime=current-runningsince
	echo "User Time (in s) from Job $jobid = $usertime"
	echo " " 
done

