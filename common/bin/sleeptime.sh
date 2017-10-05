logfile=$1

grep -i sleep $logfile|awk '{sum += $2} END {print sum/60.0," minutes,",sum,"  seconds"}'

