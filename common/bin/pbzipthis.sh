FL=`ls wrfout*`
FL="$FL "`ls *.nc`

PBZIP2=/common/SVN/common/bin/pbzip2
for f in $FL; do

	echo "Timing parallel bzip2 of $f"
	time $PBZIP2 ./"$f"

done

