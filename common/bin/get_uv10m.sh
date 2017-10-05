set -x 
param=":.GRD:10 m"
file=$1
out=$file.uv10m.grb

WGRIBMF=/common/GIT/mydael/scripts/bash/wgribmf.sh

if [ "${file##*.}" == "bin" ]; then
	$WGRIBMF $file $file.grib1
	filein=$file.grib1	
else
	filein=$file
fi

wgrib -s $filein | grep "$param" | wgrib -i -grib $filein -o $out
