

NDAYS_MAX_RETENTION=30

DIRLIST="/nas1/DATA/models/ECMWF_INDONESIA/GRID_0.125000 /nas1/DATA/models/GFSUS_GLOB/GRID_0500"


function trim_dir_info() {
	DIR=$1

	cd $DIR
	FL80=`find . -mtime +${NDAYS_MAX_RETENTION} |grep ".[89][0-9].grb"`
	FL100=`find . -mtime +${NDAYS_MAX_RETENTION} |grep ".1[0-9][0-9].grb"`
	FL="$FL80 $FL100"

	echo "In $DIR, we'd save:"
	du -shcx $FL |grep total
}


for dir in $DIRLIST; do 
	#~~
	trim_dir_info $dir

	echo "Proceed? [Y/N]"

	read answer

	if [ "$answer" == "Y" ]; then
		
		echo "Erasing files in $DIR"
		#~~
		rm -f $FL
		
		#echo $FL
	fi

done

