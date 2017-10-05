datestart=`date -u +%Y%m%d%H%M%S`
LOG=$HOME/squeue_monitoring.$datestart.log
NSECONDS=10
TIMELIMIT=3600
TIMELIMIT=60
TIMELIMIT=10800

TRUE=0
SECONDS=0
while [[ $TRUE ]]; do

	
	datestamp=`date -u +%Y%m%d%H%M%S`
	echo $datestamp >> $LOG
	squeue -o"%.7i %.9P %.32j %.8u %.2t %.10M %.8C %.6D %R" -a  >> $LOG
	sleep $NSECONDS

	let SECONDS=SECONDS+$NSECONDS

	echo "Been runnin' since $SECONDS... TIMELIMIT @$TIMELIMIT" >> $LOG

	if [ $SECONDS -gt $TIMELIMIT ]; then
		echo "Finished!" >> $LOG
		TRUE=1
		break
	fi

done
