

for f in *; do
	GRIBDATE=`wgrib -v $f|tail -1|sed "s/:/ /g" | grep -o "D=.........." | sed "s/D=//g"`
	FR=`wgrib -v $f|tail -1|sed "s/:/ /g" |awk '{print $9}' |sed "s:hr::g"`
	if [ "$FR" == "anl" ]; then	
		FR=00
	fi
	mv $f PGFSUS.${GRIBDATE}0000.00$FR.grb
done
