dir=$1
file=$dir/ddfile
count=1000000
block=1
block_unit="k"
case $block_unit in 
	k) let factor=1024;;
	m) let factor=1024*1024;;
	g) let factor=1024*1024*1024;;
	*) echo "block_unit unknown";;
esac
let size=count*block*factor

echo "Writing a $size bytes file in $file"

time sh -c "dd if=/dev/zero of=$file bs=${block}${block_unit} count=$count"

rm -f $file
