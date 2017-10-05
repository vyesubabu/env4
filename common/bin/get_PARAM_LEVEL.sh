set -x 
param=$1
level=$2
file=$3
out=$4


case $param in 
	T|TMP)
		param="TMP";;
	U|UGRD)
		param="UGRD";;
	V|VGRD)
		param="VGRD";;
	*)
		echo "Param $param unknown. Exit!"
		exit 1 ;;
esac

case $level in 
	2M|2m)
		level="2 m"
		levelstr="2M";;
	10M|10m)
		level="10 m"
		levelstr="10M";;
	*)
		echo "Level $level unknown. Exit!"
		exit 1 ;;
esac




if [ -z "$out" ]; then
	out=$file.$param.$levelstr.grib1
fi


if [ "${file##*.}" == "bin" ]; then
	WGRIBMF=/common/GIT/mydael/scripts/bash/wgribmf.sh
	$WGRIBMF $file $file.grib1
	filein=$file.grib1	
else
	filein=$file
fi

wgrib -s $filein | grep ":$param" | grep ":$level" | wgrib -i -grib $filein -o $out
