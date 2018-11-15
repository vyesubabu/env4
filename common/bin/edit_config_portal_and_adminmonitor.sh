set +x

function grepip() {
grep -o -e '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
}

module load ecfshared
module load taskcenter_config

IP2SET=$1

if [ -z "$IP2SET" ]; then
	echo "You didn't specify IP as argument .. going to ask questions"
	INTERACTIVE="ON"
else
	INTERACTIVE="OFF"
fi

if [ -z "$SMS_HOME" ] ; then
	if [ ! -z "$ECFLOW_USER" ]; then
		export SMS_HOME=/home/$ECFLOW_USER
	else
		echo "SMS_HOME not set even after module load taskcenter_config. Exiting..."
		exit 1
	fi
fi

dir=/var/www/html/portal/
## NB : there are 2 ips in core.php, currently should be identical!

pathcore=$dir/app/config/core.php 
pathmoni=$dir/app/webroot/services/moniteur.wsdl 
pathserv=$SMS_HOME/adminmonitor/htdocs/admin/scheduler/service.wsdl
pathplat=$SMS_HOME/soprano/config/config.sh 

currentip_core=`cat $pathcore | grep http | grepip|sort -u|head -1`
currentip_wsdl=`cat $pathmoni | grep http | grepip`
currentip_service=`cat $pathserv |grep http |grepip`
current_platform=`cat $pathplat |grepip`

#currentip_core=`cat $dir/app/config/core.php | grep -o "10.*:" |sed "s/://g" |sort -u`
#currentip_wsdl=`cat $dir/app/webroot/services/moniteur.wsdl  | grep -o "10.*/portal" | sed 's:/portal::g'`


echo "Ip in "
echo "core.php " $currentip_core
echo "moniteur.wsdl " $currentip_wsdl
echo "service.wsdl " $currentip_service
echo "plateforme " $current_platform

if [ "$INTERACTIVE" == "ON" ]; then

	echo "which IP do you want to assign?"
	read ip
	echo "Do you wish to replace? [Y/N]"
	read answer

else 
	ip=$IP2SET
	answer="Y"
	answermove="Y"
fi

if [ "$answer" == "Y" ]; then
cat $pathcore |sed "s:$currentip_core:$ip:g"  > $pathcore.new
cat $pathmoni |sed "s:$currentip_wsdl:$ip:g" > $pathmoni.new
cat $pathserv |sed "s:$currentip_service:$ip:g" > $pathserv.new
cat $pathplat |sed "s:$currentip_service:$ip:g" > $pathplat.new
fi

echo "############################"
echo " "
echo "  ## $pathcore.new  ##"
cat  $pathcore.new |grep $ip 
echo ""

echo " ##  $pathmoni.new ##"
cat $pathmoni.new |grep $ip 

echo " ##  $pathserv.new"
cat $pathserv.new |grep $ip

echo "  ## $pathplat.new  ##"
cat  $pathplat.new |grep $ip 

if [ "$INTERACTIVE" == "ON" ]; then
	echo ""
	echo "Replace all? [Y/N]"
	read answermove 
fi

if [ "$answermove" == "Y" ]; then
	mv $pathcore.new $pathcore
	mv $pathmoni.new $pathmoni
	mv $pathserv.new $pathserv
	mv $pathplat.new $pathplat
	echo "Replaced!"
fi




