cd /tmp


. /etc/profile.d/modules.sh
module load taskcenter/common
module load taskcenter/softwares/grib_api

set -x 
/bin/bash

# without LANG (not set by default), we cannot do any regexp! (be it with 
# sed or awk !)
export LANG=en_US.UTF-8
env  | sort -n> envtest

grib_ls -p date,time ZGWR12HKNC_PWRF.KNEW0070.20121218.Run00.12.grb.bin
grib_ls -p date,time ZGWR12HKNC_PWRF.KNEW0070.20121218.Run00.12.grb.bin > toto

cat toto  | sed -e "/.*[a-Z].*/d" -e "/^$/d" | sort -u | awk '{ printf("%d%04d\n", $1,$2) }'
