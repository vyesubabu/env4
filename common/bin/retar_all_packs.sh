#!/bin/bash
. /etc/profile.d/modules.sh
module load use.own
module load taskcenter/sms

TASKDIR=/share/apps/tasks
cd $TASKDIR
for task in `ls -1d P*/*` ; do
#for task in `ls -1d P_COSMO_KOLD0070/*` ; do
	cd $TASKDIR/$task
	make_task_tar.sh FORCE
	rephase_launchscripts.sh
done

echo "Note that we only tar project's Tasks!"
