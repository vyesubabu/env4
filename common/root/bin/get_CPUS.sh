case $LANG in
	fr_FR*) 

	lscpu | egrep '^Thread|^Core|^Socket|(par socket)|^Processeur\(' 

	echo Coeurs = $(( $(lscpu | awk '/^Socket/{ print $2 }') * $(lscpu | awk '/par socket/{ print $4 }') ))

	explanationString="Processeurs = Threads par coeur X coeurs par socket X sockets"
	;;
	en_*)

	lscpu | egrep '^Thread|^Core|^Socket|^CPU\('

	echo Cores = $(( $(lscpu | awk '/^Socket/{ print $2 }') * $(lscpu | awk '/^Core/{ print $4 }') ))

	explanationString="CPUs = Threads per core X cores per socket X sockets"

	;;
	*)
	echo "This language is not supported : grep string must be adapted first!"
	exit 1
	;;
esac


echo $explanationString
