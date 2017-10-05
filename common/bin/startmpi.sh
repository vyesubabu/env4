#!/bin/bash

#---------------------------------------------------------------------------------
#Auteur: Arnaud HERITER (MFI)
#Version 1.0 (20112105)
#Input: MPI binary to launch
#Ouput: N/A
#Description: 
# In order to run on the PSM Qlogic framework, one MPI job has to 
#  set the PSM_SHAREDCONTEXTS_MAX variable.
#  This script first call the "get_psm_sharedcontexts_max.sh" to retreive the needed ipath 
#  driver hardware context for each node on the cluster
#---------------------------------------------------------------------------------

contexts=`get_psm_sharedcontexts_max.sh`
if [ "$?" = "0" ] ; then
	export PSM_SHAREDCONTEXTS_MAX=$contexts	
fi

#Launch the binary from script arguments
$@

exit $?


