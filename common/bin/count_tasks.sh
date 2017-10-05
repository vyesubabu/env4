LOG=$1


if [ -z "$LOG" ]; then
	LOG=`ls -rt1 sms.*.log | tail -1`
fi

echo "Analysing $LOG file"

NABORTED=`cat $LOG|grep "aborted:/"|grep "production_SLURM$"|wc -l `
NCOMPLETED=`cat $LOG|grep  "complete:/"| grep "production_SLURM$"|wc -l`
NSTARTED=`cat $LOG|grep active|grep "production_SLURM$"|wc -l`
NRELAUNCHED=`cat $LOG|sed "s:#:\n#:g"| grep force|grep queued|wc -l`

echo '$NSTARTED $NRELAUNCHED $NCOMPLETED $NABORTED'
echo "$NSTARTED, $NRELAUNCHED, $NCOMPLETED, $NABORTED"
