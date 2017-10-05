
#!/bin/bash
#
# This script does stuff
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0: 20160323						      # 
#		-	Reboot certain node IDs				      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

NODES2REBOOT=$*

if [ -z "$NODES2REBOOT" ]; then
	echo "Please provide the id (09,12,32)... of the nodes you want to reboot"
	exit 1
fi

for nodeid in $NODES2REBOOT; do

	echo "Draining"
	cmsh -c "device use compute${nodeid}; drain"
	echo "Rebooting"
	pexec -n compute${nodeid} "reboot"
done

