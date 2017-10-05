SCRIPT=$1
cat $SCRIPT |grep VERSION -A2|grep "* v"|awk '{print $3}'|sed "s/://"

