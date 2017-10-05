GAD_PID=`ps -ef |grep "gad.jar"|grep -v grep|awk '{print $2}'`


lsof -p $GAD_PID |grep log 

