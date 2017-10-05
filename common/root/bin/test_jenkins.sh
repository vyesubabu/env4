function select_file_and_options(){
SELECTEDMODE=$1
SELECTEDDB=$2

case $SELECTEDMODE in
	transmet-header)
	OPTS="--header REMI01 --center CIPS"
	;;
	*)
	OPTS=""
	;;
esac

TODAY=`date -u +%Y%m%d`

case $SELECTEDDB in
	moddb|imgdb)
	file=/tmp/PGFSUS.GLOB0500.20150222.Run00.grib
	;;

	prddb)
	file=/tmp/CIPS_CAL_Training_1.2.ModDB.pdf
	date=$TODAY
	key1=CIPS
	key2=TEST
	key3=JENKINS
	OPTS="$OPTS --date=$date --key1=$key1 --key2=$key2 --key3=$key3"
	;;

	lrfdb)
	file=/tmp/PGFSUS.GLOB0500.20150222.Run00.grib
	date=$TODAY
	Model=CIPS
	Type=TEST
	SubType=JENKINS
	OPTS="$OPTS --date=$date --key1=$Model --key2=$Type --key3=$SubType"
	;;

	*)
	echo "which db is this $SELECTEDDB?"
	exit 1
	;;
esac

}

###########################################################"
# 		MAIN

## test
MODES="transmet-header"
DATABASES="lrfdb"

MODES="cips_debug cips transmet-header"
DATABASES="moddb prddb lrfdb"

test_counter=1
error_counter=0
success_counter=0

for mode in $MODES; do
for db in $DATABASES; do 

	#~~ select file & options depending on mode & db
	select_file_and_options $mode $db

	echo "sending for test $test_counter ... mode=$mode; db=$db"	

	cips_send.py --mode $mode --database $db $OPTS --files $file &> /dev/null
	result=`echo $?`

	echo "test${test_counter} = $result"
	if [ $result -eq 0 ]; then
		let success_counter=success_counter+1
	else	
		let error_counter=error_counter+1
	fi
	let test_counter=test_counter+1
done
done




