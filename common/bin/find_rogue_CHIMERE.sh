
TODAY_BD=`date +%b%d`

ps -aef|grep sms|grep CHIMERE > /tmp/CHIMERE.processes


#echo "removing today's processes from list to figure out rogue processes"
#cat /tmp/CHIMERE.processes | grep -v "$TODAY_BD" 


cat /tmp/CHIMERE.processes | grep -v "$TODAY_BD"  | awk '{print $2}' > /tmp/CHIMERE.roguePID.processes

PID_ROGUE=`paste -s /tmp/CHIMERE.roguePID.processes`

if [ ! -z "$PID_ROGUE" ]; then

	echo "kill -9 $PID_ROGUE"
	kill -9 $PID_ROGUE
else 
	echo "No rogue processes on $HOSTNAME"

fi
