cd /scratch/data/archipel
echo "Cleaning $PWD for files older than 1 day"
find . -type f -mtime +1 |xargs rm -f
find . -type d -empty |xargs rm -rf

cd /scratch/SMS/sms/workdir
echo "Cleaning $PWD for files older than 1 day"
find . -type f -mtime +1 |xargs rm -f
find . -type d -empty |xargs rm -rf
