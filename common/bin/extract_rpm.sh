function extract_rpm() {
	RPM=$1
	rpm2cpio $RPM | cpio -idv
}


RPM2EXTRACT=$*
NRPM2EXTRACT=`echo $RPM2EXTRACT | wc -w`

if [ -z "$RPM2EXTRACT" ]; then
	echo "Missing RPM as argument..."
	exit 1
else
	echo "This will extract $RPM2EXTRACT in $PWD... Proceed? "
	echo "Enter Y to continue"
	echo "Enter R to relocate somewhere"
	echo "Enter N to abort"
	read answer
	case $answer in
		Y)
			rpm2cpio $RPM2EXTRACT | cpio -idv
		;;
		R) 
			echo "Enter path that you want to relocate to"
			read path2reloc
			set -e
			mkdir -p $path2reloc
			cp $RPM2EXTRACT $path2reloc
			cd $path2reloc

			for RPM in $RPM2EXTRACT; do
				extract_rpm $RPM
			done
		;;
		*)
			echo "Aborting.."
		;;
	esac

fi 

#export ins=foo-bar.rpm

