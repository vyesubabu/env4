#RERUN_LIST=`gen_datelist.bash 20131111000000 20131121000000 12 hours`

function resend_allfiles() {

DATE=$1
YYYYMMDD=`echo $DATE |cut -c1-8`
HHMM=`echo $DATE |cut -c9-12`

cd /scratch_fhgfs/WEX/WRFULL/
ASSIM_FILES=`ls *${YYYYMMDD}*/*${HHMM}*/WRF/run/PBZIP.ANALYSIS/*`
FORECAST_FILES=`ls *${YYYYMMDD}*/*${HHMM}*/WRF/run/PBZIP.ASSIM/*`

for f in $ASSIM_FILES; do
	## resend
	echo "resending $f to /nas/models/PWRFULL/INDO3DOM on 10.0.0.200"
#	scp $f root@10.0.0.200:/nas/models/PWRFULL/INDO3DOM
done
for f in $FORECAST_FILES; do
	## resend
	echo "resending $f to /nas/models/PWRFULL/INDO3DOM on 10.0.0.200"
	scp ./"$f" root@10.0.0.200:/nas/models/PWRFULL/INDO3DOM
done
}



### OPTIONAL MAIN
#
## If you know the list to resend...
#RERUN_LIST=`gen_datelist.bash 20131115120000 20131121000000 12 hours`
RERUN_LIST="20131121120000"

for date in $RERUN_LIST; do
	echo "resending $date"
	resend_allfiles $date
	
done

#####MAIN 
resend_allfiles
