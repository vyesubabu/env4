#!/bin/bash
export DMT_PATH_EXEC=$HOME/T_NEW_TASK
export DMT_DATE_PIVOT=TODAY
export DMT_ECHEANCE=000000
export SCRATCHDIR="/scratch"
export PARALLEL_TASK="YES"
export PARALLEL_TASK="NO"

export MODULE="myownprivateModule"

export TASKNAME="TASKNAME.TBD"

export NNODES="1"

###########################################"
### Do Not Edit Below this line
module load slurm/14.03
let NCORES=NNODES*32
let NPROCESS_MPI=NNODES*2

set -x

export HOST=localhost
TMPDIR=$SCRATCHDIR/tmp/$LOGNAME/exec.$$
[[ -d $TMPDIR ]] || mkdir -p $TMPDIR ; cd $TMPDIR

if [ "$PARALLEL_TASK" == "YES" ]; then
	 sbatch -J "$TASKNAME" --ntasks-per-node 2 -c 16 -n $NPROCESS_MPI -p dev $DMT_PATH_EXEC/launch.sh $MODULE
else
	$DMT_PATH_EXEC/launch.sh $MODULE
fi

echo "cd $TMPDIR" 
