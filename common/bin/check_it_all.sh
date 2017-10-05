#!/bin/bash
#
# This script performs extensive checks & sends emails should any of them fail
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0: 20140101						      # 
#		-							      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
check_partitions_saturation() {
	error=0
	/common/bin/find_saturated_disks
	error=$?
	return $error 
}

check_nodes_status() {
	error=0
	NDRAINED=`sinfo|grep drain`
	if [ ! -z "$NDRAINED" ]; then
		echo "At least one drained node !"
		echo $NDRAINED
		error=2		
	fi
	return $error
}

function perform_check() {
	
	cat=$1

	case $cat in

		PARTITIONS) 
			#~~
			check_partitions_mounting
			e_csm=$?

			#~~
			check_partitions_saturation
			e_csp=$?


			let total_error=total_error+e_csp+e_csm
			;;

		NODES)
			#~~ 
			check_nodes_status
			e_cns=$?

			let total_error=total_error+e_cns
			;;
		PORTAL) 
			#~~
			check_portal
			;;
		SBATCH) 
			#~~
			check_sbatch
			;;
		SLURM) 
			#~~
			check_slurm_config
			;;
		*) 
			echo "Unknown category $cat .. aborting"
			exit 1
			;;
	esac

}

MAILTO="montrotyr@mfi.fr"

CHECK_CATEGORIES="SLURM NODES PORTAL PARTITIONS SBATCH"
CHECK_CATEGORIES="NODES"

## Things to check
# 
#  - integ / oper / dev partitions exist
#  - portal up & accessible
#  - /scratch_fhgfs up, writable & mounted everywhere
#  - other partitions mounted everywhere
#  - sbatch of a simple script to queue dev works
#
total_error=0

for category in $CHECK_CATEGORIES ; do

	#~~
	perform_check $category

done

if [ $total_error -ne 0 ]; then 

	echo "Mailing $MAILTO since errors have been found"
	mail -s "Errors on the Task Center, as detected by $0" $MAILTO <<EOF
Check asap!
EOF


fi
