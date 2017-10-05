
for obstype in temp metar synop ;do

	echo "FOR $obstype:"
	cat *.$obstype.lr|awk '{print $4}'|grep [a-Z]|sort -u
done
