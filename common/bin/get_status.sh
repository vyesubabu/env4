#!/bin/bash
#
# This script gets scheduler status
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jan, 01  2013     #
#                                                                             #
#   VERSION :								      #
#	* v4.0b1: 20171030						      # 
#		- Add: ecfportal01 with ens32 as eth
#	* v3.3b2: 20170222						      # 
#		- Add: CSRTBI02
#	* v3.3b1-rev2: 20151117					      # 
#		- Add: CSRJAN & merge
#	* v3.3b1: 20150723						      # 
#		- Add: CSOGAS/CSIGAS
#	* v3.2.0-rev1: 20140917						      # 
#		- Add: cipsbmkg@googlegroups.com for warnings
#		- Mod: in case of manual assignment of virtual ip to CSOJAN
#		review IPV assignment & tests
#	* v3.2b2-rev1: 20140310						      # 
#		- Mod: add path to /sbin
#	* v1.0.1: 20140217						      # 
#		- Modified for miniHPC ips				      #
#	* v1.0.0: 20131002						      # 
#		-							      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

OFFICIAL_ADMIN_GROUP_EMAIL="montrotyr@mfi.fr"

function email1() {
/usr/bin/mutt -s "Task Center status problem" $OFFICIAL_ADMIN_GROUP_EMAIL <<EOF
Script $0 ran on $HOSTNAME but some issue in IP configuration: detected $IPV as virtual ip but not correct
EOF
}
function email2() {
/usr/bin/mutt -s "Task Center status problem" $OFFICIAL_ADMIN_GROUP_EMAIL <<EOG
Script $0 ran on $HOSTNAME but some weird issue in IP configuration: detected virtuals ips
IPV1=$IPV1	
IPV2=$IPV2	
IPV=$IPV	
EOG
}
case $HOSTNAME in
	CSIJAN|CSOJAN|CSSJAN|CSRJAN)		
		interface=eth1;;
	CSRTBI02|CSRGAS)		
		interface=eth1;;
	CSITLI|CSOTLI)		
		interface=eth0:0;;
	CSIGAS|CSOGAS)		
		interface=eth0;;
	ecfportal*)		
		interface=ens32;;

	*)
		interface=eth0;;
esac
	
# virtual ip defined by Pacemaker
IPV1=`/sbin/ip addr |grep "secondary $interface"|awk '{print $2}'|sed "s:/.*::g"`
# virtual ip defined manually (in case of override)
IPV2=`/sbin/ip addr |grep "global ${interface}:0"|awk '{print $2}'|sed "s:/.*::g"`
IPR=`/sbin/ip addr |grep "global $interface"|awk '{print $2}'|sed "s:/.*::g"`

if [ -z "$IPV1" ] && [ -z "$IPV2" ]; then
	IP=$IPR
	case $IPR in 
		10.0.15.221|192.168.202.2|10.0.15.217|10.0.15.189)
			status="OPER" 
			;;
		172.19.22.15|172.19.22.16)
			status="STANDBY" 
			;;
		172.19.22.18|10.0.15.123|10.0.15.222|192.168.202.4)
			status="INTEGRATION" 
			;;
		172.19.22.170)
			status="RCC" 
			;;
		*) 
			echo "Unknown IP / State. Check"
			exit 1
			;;
	esac
		
else ## at least one IP virtual detected
	#echo "At least one virtual IP detected" 
	if [ -z "$IPV1" ] && [ ! -z "$IPV2" ]; then
		IPV=$IPV2
	elif [ -z "$IPV2" ] && [ ! -z "$IPV1" ]; then
		IPV=$IPV1
	else 
		echo "Weird configuration! Please report admin!"
		email2

	fi

	case $IPV in 
		172.19.22.17)
			status="OPER" ;;
		*)
			echo "Some virtual ip $IPV but not a scheduler"
			echo "Some virtual ip $IPV on $HOSTNAME. Not correct. Please report admin!"
			email1
			exit 1;;
	esac
fi

echo $status



