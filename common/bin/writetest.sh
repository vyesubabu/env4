dir=$1

if [ -z "$dir" ]; then

	echo "$0 requires a directory as argument... exiting..."
	exit 1

fi


function createdir() {

  subdir=$1
  permissions=$2
  mkdir -p $subdir
  chmod $permissions $subdir
  echo "$subdir is created with permissions $permissions"
}

  
set +x

UNIT=1M
NBLOCKS=10

OUTFILE=$dir/SMS/write_test.$$
echo "Writing $NBLOCKS * $UNIT"

WEXGFS=$dir/WEX/GFS

time dd if=/dev/zero of=$OUTFILE bs=$UNIT count=$NBLOCKS #&> /dev/null

if [ $? -eq 0 ]; then
	echo "Could write!"
	rm -f $OUTFILE
	createdir $WEXGFS 777
	if [ -d $WEXGFS ]; then
		createdir  $dir/tmp 777
	else
		echo "Failed to create $WEXGFS"
		exit 1
	fi
	exit 0
else
	echo "Couldn't write!"
	exit 1
fi

	


