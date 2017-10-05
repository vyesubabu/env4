
set -x
file=$1
if [ -z "$file" ]; then
	echo "missing file as argument"
	exit 1
fi

nf=`echo $file | sed "s: :_:g"`

cp "$file" $nf

