#!/bin/bash
#
# This script restarts FhGFS clients on all servers (to be used when 
# fhGFS is completely down)
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI PIEPLU                                   Jan, 01  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0: 20140101						      # 
#		- 							      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

cd /
umount -fl /scratch_fhgfs

#Stop all fhgfs client 
service fhgfs-client stop 
pexec -n=CSOTLI,CSITLI "umount -fl /scratch_fhgfs ; service fhgfs-client stop"
pexec -n=compute01..compute06 "umount -fl /scratch_fhgfs ; service fhgfs-client stop"

#Stop services on Impmaster
service fhgfs-helperd stop
service fhgfs-mgmtd stop
service fhgfs-meta stop

#Delete all conf
echo "Delete all files in /local"
rm -fr /fhgfs-meta/*
rm -fr /fhgfs-mngt/*
rm -fr /local/*

#Stop all storage servers on all nodes
#Delete all in /local
pexec -n=compute01..compute06 "service fhgfs-helperd stop ; service fhgfs-storage stop ; rm -fr /local/*"
sleep 10
#Redo the action to be sure
pexec -n=compute01..compute06 "service fhgfs-helperd stop ; service fhgfs-storage stop ; rm -fr /local/*"

# Restart fhgfs managment services 
service fhgfs-mgmtd start
service fhgfs-meta start

sleep 30

#Start all storage servers
#service fhgfs-storage start
service fhgfs-helperd start
pexec -n=compute01..compute06 "service fhgfs-helperd start ; service fhgfs-storage start"

#Start all clients
sleep 30 
service fhgfs-client start
pexec -n=compute01..compute06 "service fhgfs-client start"

#Restart scheduler nodes 
pexec -n=CSOTLI,CSITLI "service fhgfs-client start"
