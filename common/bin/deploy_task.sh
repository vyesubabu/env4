## Target Machine, Path & User
echo "This should be run as user sms on vcipssched"
echo ""
echo "From  the information provided by the developer in the Task Portal, please answer the following questions :"

echo "Name of the storage computer for source files?"
read src_machine
echo "Do you have root access on this machine [Y/N]?"
read rootaccess
if [ "$rootaccess" == "Y" ] || [ "$rootaccess" == "y" ];  then
	src_user=root
else
	echo "Provide a username for which you will have an account on $src_machine"
	read src_user
fi
echo "What is the Folder of the source files on $src_machine?"
read src_path

#src_machine=cipsdev1
#src_user=root
#src_path=/home/montrotyr/T_SAT_KALPANA_CC_FOR_VISUMET

## Task Details


echo "What is the Task Pack (tgz file)?"
read PackName
## Basic checks of FileNaming Convention
fchar=`echo $PackName |cut -c1`
schar=`echo $PackName |cut -c2`
sixthchar=`echo $PackName |cut -c6`
if [ "$fchar" != "T" ] || [ "$schar" != "_" ] || [ "$sixthchar" != "_" ]; then
  echo "PackName should be of the form : T_???_"
  echo "Abort.."
  exit 1
fi

echo "Based on PackName, the TaskName should be ${PackName%%.tgz*}. Confirm [Y/N]?"
read answer
if [ "$answer" == "Y" ] || [ "$answer" == "y" ];  then
        TaskName=${PackName%%.tgz*}
else
        echo "Provide the TaskName for this Pack"
        read TaskName
fi

FullBaseName=`echo $TaskName | sed "s:^._::g"`
ProjectName=P_$FullBaseName

echo "Based on TaskName, the ProjectName should be ${ProjectName}. Confirm [Y/N]?"
read answer
if [ "$answer" == "Y" ] || [ "$answer" == "y" ];  then
        echo "Task Structure will be $ProjectName/$TaskName"
else
        echo "Provide the ProjectName for this Task : $TaskName"
        read $ProjectName
fi

echo 'What is the Launch script name [default= launch.sh?]'
read LaunchScript
if [ -z "$LaunchScript" ]; then 
	LaunchScript="launch.sh"
fi

#TaskName=TOTO_GOES_TO_BOLLYWOOD
#TaskName=T_SAT_KALPANA_CC_FOR_VISUMET
#PackName=$TaskName.tgz
#LaunchScript=launch.sh
#MasterScript=master.sh



#############################################
# 	NO EDITING BELOW THIS BOX
#############################################
## Target Machine, Path & User
tgt_machine=vcipssched
#tgt_machine=cipsschedop
tgt_user=sms
tgt_path=/common/task

#
# Check who we are and where we are

me=`echo $LOGNAME`
current_machine=`echo $HOSTNAME`
echo "You are currently $me on $current_machine"
is_vcipssched=`/sbin/ifconfig | grep "192.168.4.75"`

if [ ! -z "is_vcipssched" ] && [ "$me" == "sms" ] ; then
#if [ "$me" == "sms" ] &&  [ [ "$current_machine" == "cipsschedop" ] ||  [ "$current_machine" == "cipsschedstdby" ] ] ; then
	## Build the list of Existing Families:
	cd $tgt_path
	FamiliesList=`find [a-Z]* -type d -maxdepth 0`

	Family=`echo $TaskName | awk 'BEGIN { FS = "_"};{ print $2 }'`
	greppedFamily=`echo $FamiliesList|tr " " "\n"|grep $Family`

	if [ "$greppedFamily" == "$Family" ]; then
		
		TaskFullPath=${tgt_path}/$Family/$ProjectName/$TaskName

		## Print diagnostics
		#set -x
		echo "Following steps will now be performed :"
		echo ""
		#echo "I/         ssh $tgt_user@$tgt_machine mkdir -p ${tgt_path}/$Family/$Project/$TaskName"
		echo "         mkdir -p $TaskFullPath"
		echo ""
		#echo "II/        scp ${src_user}@$src_machine:$src_path/$PackName $tgt_user@$tgt_machine:${tgt_path}/$Family/$Project/$TaskName"
		echo "        scp ${src_user}@$src_machine:$src_path/$PackName $TaskFullPath"
		echo ""
		#echo "III/       scp ${src_user}@$src_machine:$src_path/$LaunchScript $tgt_user@$tgt_machine:${tgt_path}/$Family/$Project/$TaskName"
		echo "       scp ${src_user}@$src_machine:$src_path/$LaunchScript $TaskFullPath"
		echo ""

		echo "Proceed? [Y/N]"
		read answer
		if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
			mkdir -p $TaskFullPath
			scp ${src_user}@$src_machine:$src_path/$PackName $TaskFullPath
			scp ${src_user}@$src_machine:$src_path/$LaunchScript $TaskFullPath
		fi

		## Print the resulting Task directory
		cd  $TaskFullPath
		ls -lrt
	else
		echo "We use the second item from TaskName=$TaskName as Family, i.e. $Family"
		echo ""
		echo "Family $Family is not a valid family. Please make sure your task respects the CIPS File Naming Convention"
		echo ""
		echo "Aborting"
		echo ""
		exit 1
	fi
else
	echo "Run this script as user sms on vcipssched please."
	exit 1

fi
