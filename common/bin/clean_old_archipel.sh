cd /scratch/data/archipel
echo "Cleaning files older than 3 days in $PWD ..."
find . -type f -mtime +3 |xargs rm -f

cd /scratch/data/archipel/ascat
echo "Cleaning files older than 1 days in $PWD ..."
find . -type f -mtime +1 |xargs rm -f
