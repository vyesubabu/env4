
set +x 
FL=`ls -1 *sta_interpolation*`
FL=$*

for f in $FL; do

## Only works for COSMO
#	nprocx=`grep "nprocx"  $f |awk '{print $2}'`
#	nprocy=`grep "nprocy"  $f |awk '{print $2}' `
#	let NCORES=nprocx*nprocy
#	ttime=`grep "Total time" $f|awk '{print $5}'`


## works for any job
 	jobid=`echo ${f##*_}`; 
	ttime=`qacct -j $jobid |grep ru_wallclock|awk '{print $2}'`; 
	ncores=`qacct -j $jobid |grep "^slots"|awk '{print $2}'`; 
	echo $f " $ncores cores , $ttime seconds to run"
done

