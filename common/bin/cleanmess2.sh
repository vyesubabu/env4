
cd /scratch/data/models
find ./*LAT* -type f> list
find ./*_ -type f >> list

mv `cat list` .

find ./*_LAT* -type d |xargs rm -rf
find ./*_ -type d |xargs rm -rf


