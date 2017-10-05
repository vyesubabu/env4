function list_simple() {
	cat $FL |awk 'BEGIN {FS=";"} {print $3}'|sed 's:nom_ress=::g'|sort -u | sort -n >> $MAINDIR/$TODAY.$src.csv
}
function list_moddb_completed() {
	cat $FL |grep COMPLETED|awk 'BEGIN {FS=";"} {print $3}'|sed 's:nom_ress=::g'|sort -u | sort -n >> $MAINDIR/$TODAY.$src.completed.csv
}
function list_moddb_singleAD() {
	cat $FL |grep -v COMPLETED|awk 'BEGIN {FS=";"} {print $3}'|sed 's:nom_ress=::g'|sort -u | sort -n >> $MAINDIR/$TODAY.$src.singleAD.csv
}
## Number of days to include in the log analysis
NDAYS=7

MAINDIR=/home/sms/journal/sms/gad

SOURCE_LIST='fromHPC imgdb prddb moddb'
TODAY=`date -u +%Y%m%d%H%M%S`

set -x

for src in $SOURCE_LIST ; do 
  echo "Processing $src ..."   

	cd $MAINDIR/$src
	FL=`find . -type f -name "201*" -mtime -${NDAYS} |sort|grep -v bz2|grep -v csv`
 
  echo "using $FL for detection of received advisories"
 
  case $src in 

       moddb)
             list_moddb_completed 
             list_moddb_singleAD
             ;;
             
       imgdb|prddb|fromHPC)
             list_simple
             ;;
        *)
             echo "Source $src unknown. Aborting"
             exit 1 
             ;;
  esac


done


