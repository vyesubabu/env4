#!/bin/bash

function mailme() {
subject=$*
mail -s "$subject" -a /home/sms/scheduler_restart.log montrotyr@mfi.fr <<EOF
From $HOSTNAME
EOF
}


LOGGAD=/cm/shared/apps/SMS/logs/smslogs/`/common/bin/get_status.sh`/gad.log


if [ "$USER" == "sms"  ]; then
cd /home/sms/
rm -f /home/sms/scheduler_restart.log


cat $LOGGAD |grep java.lang.OutOfMemoryError
result_gad=$?



./startstop_monitor status &> /dev/null
result=$?

if [ $result -ne 0 ] || [ $result_gad -eq 0 ]; then 

	if [ $result_gad -eq 0 ]; then
		echo "GAD.log seems to have crashed on OOME"
		GAD_ID=`ps -ef |grep gad.jar|grep -v grep|awk '{print $2}'`
		kill -9  $GAD_ID	
		echo "killing GAD"
		mv $LOGGAD $LOGGAD.crashed.`date -u +"%Y%m%d%H%M"`
		echo > $LOGGAD
	fi
	
	echo "restarting Task Scheduler"
	./startstop_monitor start &> /home/sms/scheduler_restart.log
	./startstop_monitor status &> /dev/null
	result=$?
	if [ $result -ne 0 ]; then 
		mailme "Scheduler Restart Failed"
		echo "Major mistake. Restarting failed"
	else
		#rm -f /home/sms/scheduler_restart.log
		echo "Restart worked"
		mailme "Scheduler Restart Worked"
	fi

else		

	echo "Task Scheduler in nominal conditions"
	mailme "Scheduler Restart Not needed"

fi
else
	echo "run this as user sms on scheduler"
fi

DIRS2CREATE="/scratch_fhgfs/WEX /scratch_fhgfs/tmp"

for dir in $DIRS2CREATE; do

	[[ -d $dir ]] || mkdir -p $dir
	chmod 777 $dir
done
