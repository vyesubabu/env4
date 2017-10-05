#!/bin/bash
#
# This script generates the Tasks list for the Logbook
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Mar, 25  2015     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.1: 20150326						      # 
#		- Add "latest" file
#	* v1.0.0: 20150325						      # 
#		- Version to be tested in CSIJAN/CSOJAN			      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

SUITE_FAMILIES_TO_SKIP="management user1 PastWRF"

PARSE_DEF=/common/bin/parse_def.pl

## Prepare directory tree for files
SMS_STATUS=`/common/bin/get_status.sh`
case $SMS_STATUS in 
	INTEGRATION|OPER)
		TASKLIST_DIR=/cm/shared/apps/SMS/logs/TASKLIST/${SMS_STATUS}
		[[ -d $TASKLIST_DIR ]] || mkdir -p $TASKLIST_DIR
	;;	
	*)
		echo "SMS status $SMS_STATUS is not valid.. please check on $HOSTNAME"
		exit 1
	;;
esac



string2skip=""
for item in $SUITE_FAMILIES_TO_SKIP; do
	string2skip="($item)|$string2skip"	
done

string2skip=`echo $string2skip |sed "s:|$::"`

echo "string2skip="$string2skip



/home/sms/bin/cdp <<EOF
login localhost sms 1 
get
show &> all.def
quit
EOF

#exit

date=`date -u +%Y%m%d%H%M%S`

# Generate all filenames
OUTFILE=TaskList_${date}_${HOSTNAME}.txt
FINAL_TASKLIST=TaskList_complete_${date}_${HOSTNAME}.txt
CSV4LOGBOOK=$TASKLIST_DIR/TaskList_complete_${date}_${SMS_STATUS}.csv
LATEST_CSV4LOGBOOK=TaskList_complete_latest_${SMS_STATUS}.csv

#cat all.def | ./parse_def.pl > $OUTFILE
cat all.def | $PARSE_DEF > $OUTFILE

echo "Total tasklist is here: $OUTFILE"


echo "Final tasklist is here: $FINAL_TASKLIST"
cat $OUTFILE |awk 'BEGIN {FS=";"} {print $1}'|grep -vE "$string2skip" > $FINAL_TASKLIST

## Prepare eligible TaskList
cat $FINAL_TASKLIST|sed "s:/:;:g"|sed "s:^;::g" >  tmp.TaskList.csv

diff tmp.TaskList.csv $TASKLIST_DIR/$LATEST_CSV4LOGBOOK
samefile=$?

if [ $samefile -eq 0 ]; then

	## files are the same
	echo "TaskList not updated. Latest file is $LATEST_CSV4LOGBOOK"
	rm -f tmp.TaskList.csv
	
else
	
	## files are different
	mv  tmp.TaskList.csv $CSV4LOGBOOK
	cd $TASKLIST_DIR
	ln -sf $CSV4LOGBOOK $LATEST_CSV4LOGBOOK
	echo "TaskList updated. Latest file is $LATEST_CSV4LOGBOOK linked to $CSV4LOGBOOK"

fi
cd -
echo "CSV for the LOGBOOK is here: $CSV4LOGBOOK"

## cleanup 
rm -f all.def TaskList*.txt

