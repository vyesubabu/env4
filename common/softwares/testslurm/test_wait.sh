#!/bin/bash
#SBATCH -o /ecfshared/v4.0/common/softwares/testslurm/myjob.%j.%N.out 
#SBATCH -D /ecfshared/v4.0/common/softwares/testslurm
#SBATCH -J Jobname 
###SBATCH --get-user-env 
###SBATCH --clusters=mpp2
#SBATCH --ntasks=2
### multiples of 28 for mpp2
#SBATCH --mail-type=end 
#SBATCH --mail-user=montrotyr@mfi.fr
#SBATCH --export=NONE 
#SBATCH --time=00:00:30 


####
#	https://www.lrz.de/services/compute/linux-cluster/batch_parallel/example_jobs/
#source /etc/profile.d/modules.sh
#cd $SCRATCH/mydata
#mpiexec $HOME/exedir/myprog.exe
sleep 20

echo "Yes!!"
