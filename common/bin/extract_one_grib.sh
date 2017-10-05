file=$1
recordlist=$2

usage() {
echo $0 file 1:2:14:152
}

if [ -z "$recordlist" ]; then

	wgrib $file| head -n 1 | wgrib -i $file -grib -o $file.one.grb
else
	RECLIST=`echo $recordlist | sed "s/:/ /g"` 
	for rec in $RECLIST ; do
		wgrib $file | egrep "(^$rec:)" | wgrib -i $file -o tmp
		cat tmp >> $file.several.grb
	done
fi


