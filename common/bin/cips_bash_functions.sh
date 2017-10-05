#!/bin/bash
#
OK=0
KO=9999
#echo "DO NOT SOURCE THIS FILE : exit codes would terminate your session"
# just execute it :  ./cips_bash_functions.sh

### F1 : info
function info() {
	echo `date` $1
}

### F2 : testing the number of empty files in a directory
function void_files_in_dir() { 
	filelist=`ls $1`; 
	cd $1
	counter=0; 
	for f in $filelist; do 
		if [ ! -s "$f" ]; then 
			let counter=counter+1;
		fi; 
	done;  
	echo   "in dir $1 , we have $counter void files"; 
	if [ $counter -eq 0 ]; then
		return $OK
	else
		return $counter
	fi
}


### F3 : testing the number of files in a directory
#      if its an empty dir, return 0 else the number of files
function nbr_files_in_dir() {
	filelist=`ls $1`;
	cd $1
	if [ -z "$filelist" ]; then
		info "No files found in $1"
		return $KO
	else
		nfiles=`ls $1 | wc -l`
		echo   "in dir $1 , we have $nfiles files"; 
		return $nfiles
	fi
}


### F4 : testing if all files are empty
#   returns 0 if it is the case, 1 otherwise
function allvoid_files_in_dir() {
	nbr_files_in_dir $1
	nfiles=$?
	void_files_in_dir $1
	voidfiles=$?

	if [ $voidfiles -eq $nfiles ]; then
		echo "All files are empty files..."
		ABORT=1
		return $KO
	elif [ $voidfiles -eq 0 ]; then
		echo "No files are empty files..."
		return $OK
	else 
		echo "Some files are empty files..."
		ABORT=1
		return $KO
	fi
#	if [ $nfiles -eq $KO ] || [ $voidfiles -eq $KO ]; then
#		return $KO
#	fi
}


### F5 : tests if there is invalid input in the 
#   input directory
function invalid_input_in_dir() {
	ABORT=0
	nbr_files_in_dir $1 
	nfiles=$?
	allvoid_files_in_dir $1 
	allvoid=$?

	if [ $allvoid -eq $KO ] || [ $nfiles -eq $KO ] || [ $ABORT -eq 1 ]; then
	   echo "Invalid input files... "
	   echo "All void = $allvoid , number of files = $nfiles"
	   exit $KO
	else
	   return $nfiles
	fi 
}


### F6 : returns which subdirectories are older than $2 day(s) from dir $1
function ndays_old_subsdirs_of_dir() {
	if [ ${#} -ne 2 ]; then
		echo "Syntax should be : ndays_old_subsdirs_of_dir dir ndays_after_which_subdir_is_old"
	fi
	find $1 -maxdepth 1 -mtime +$2 -type d |sort -n
}

### F7 : returns which files are older than $2 minute(s) from dir $1
function nminutes_old_files_in_dir() {
	if [ ${#} -ne 2 ]; then
		echo "Syntax should be : nminutes_old_files_in_dir dir nminutes_after_which_files_are_old"
	fi
	#find $1 -mmin +$2 -type f -maxdepth 1|sort -n
	find $1 -mmin +$2 -type f |sort -n
}

### F8 :  returns which subdirectories are older than $2 minute(s) from dir $1
function nminutes_old_subdirs_in_dir() {
        if [ ${#} -ne 2 ]; then
                echo "Syntax should be : nminutes_old_subdirs_in_dir dir nminutes_after_which_subdirs_are_old"
        fi
        find $1 -maxdepth 1 -mmin +$2 -type d |sort -n
}


### F9 : if LCEC not equal to 0, it can be sent to SMS that we are aborting
function smsabort_on_failure() { 
	ec=`exitcode`
	if [ $ec -ne 0 ]; then 
	  echo "SMS Abort sent. Exiting..."
	  smsabort
	  exit 1
	fi
}


### F10 : get filesize
function filesize() { 
	file=$1
	if [ -z "$file" ]; then
	   echo "Use is : filesize somefile"
	fi
	size=`ls -lrt $1|awk '{print $5}'`
	echo $size
	#return $size
}


### F11 : remaining space in Gb in dir
function space_left_in_dir() { 
	dir=$1
	if [ -z "$dir" ]; then
	   echo "Use is : space_left_in_dir somedir"
	fi
	spaceleft=`df -h $dir |grep / | awk '{print $4}'`
	echo $spaceleft
}


### F12 : latest file(s) in all subdir(s)
function latest_files_in_dir() { 
	maindir=$1
	nfiles=$2
	if [ -z "$maindir" ]; then
	   echo "Use is : latest_files_in_dir some_main_dir number_files_needed"
	   echo "Example : latest_files_in_dir /tmp 5"
	#   exit 0
	fi
	if [ -z "$nfiles" ]; then
	   echo "Default: returns only the latest file"
	   nfiles=1    
	fi
	subdirs=`find $maindir -type d`
	for d in $subdirs;do
		lf=`ls -ltr $d |tail -$nfiles|awk '{print $9}'`; 
		echo "## "$d" ## :" $lf; 
	done
}

### F13 : percentage used of disk
function disk_use() { 
	disk=$1
	if [ -z "$disk" ]; then
	   echo "Use is : disk_use some_disk"
	   echo "Example : disk_use /dev/sda1"
	fi
	pct_used=`df -h $disk |grep "/" |awk '{print $3/$2}'`
	echo $pct_used
}

### F14 : CIPS Banners
function cb_host() { 
echo "-------------" | $COMMON_HOME/bin/figlet -f $COMMON_HOME/share/cips_resources/fonts/banner.flf
echo "Running on $HOSTNAME" | sed "s:[0-9]: & :g" | tr '[:lower:]' '[:upper:]' | $COMMON_HOME/bin/figlet -f $COMMON_HOME/share/cips_resources/fonts/small.flf
echo "-------------" | $COMMON_HOME/bin/figlet -f $COMMON_HOME/share/cips_resources/fonts/banner.flf
}
function cb_start() { 
cat $COMMON_HOME/share/cips_resources/cipshdr_START
}
function cb_get() { 
cat $COMMON_HOME/share/cips_resources/cipshdr_GET_DATA
}
function cb_send() { 
cat $COMMON_HOME/share/cips_resources/cipshdr_SEND_DATA
}
function cb_end() { 
cat $COMMON_HOME/share/cips_resources/cipshdr_END
}

### F15 : exporting functions globally
function functionslist() {
grep "^function" $COMMON_HOME/bin/cips_bash_functions.sh |awk '{print $2}'|sed "s:[()]::g"
}
function exportcipsfunctions() {
for func in `functionslist`; do
export -f $func
done
}


### F16 : date functions
function date14_to_fmt() {
 date=$1
 day=`echo $date |cut -c1-8`
 hour=`echo $date |cut -c9-10`
 min=`echo $date |cut -c11-12`
 sec=`echo $date |cut -c13-14`
 fmt_date="$day ${hour}:${min}:${sec}"
 echo $fmt_date
}
function datefmt_to_14() {
 day=$1
 hhmmss=$2
 hour=`echo $hhmmss |cut -c1-2`
 min=`echo $hhmmss |cut -c4-5`
 sec=`echo $hhmmss |cut -c7-8`
 date14="$day${hour}${min}${sec}"
 echo $date14
}
function date14_to_fmtdash() {
 date=$1
 year=`echo $date |cut -c1-4`
 month=`echo $date |cut -c5-6`
 day=`echo $date |cut -c7-8`
 hour=`echo $date |cut -c9-10`
 min=`echo $date |cut -c11-12`
 sec=`echo $date |cut -c13-14`
 fmt_date="${year}-${month}-${day} ${hour}:${min}:${sec}"
 echo $fmt_date
}
function fmtdash_to_date14() {
 date="$1 $2"
 date14=`date --date="$date 0 hours" +%Y%m%d%H%M%S`
 echo $date14
}


## F17 : sendok function
function sendok() {
tsendok=`echo $?`
if [ $tsendok -eq 1 ] ; then
        echo " ";
        echo "At least one of the file transfers did not work";
        echo "ABORTING!"
        smsabort
fi
}
### F18 : spaced printing for debug
function cleanprint() {
NSPACES=3
for i in `seq 1 $NSPACES`; do echo " "; done
echo "$*"
for i in `seq 1 $NSPACES`; do echo " "; done
}
