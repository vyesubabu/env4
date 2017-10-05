cd /cm/images

[[ $? ]] || exit 1

TARGET=/Assim/BACKUPS
[[ -d $TARGET ]] || mkdir -p $TARGET

for image in `ls  -1d *-image` ; do


	echo "Tarring $image into $TARGET... Please standby"
	tar cvfz $TARGET/$image.tgz $image/*

	echo "...."
	echo "Done"	
	echo ""	

done
