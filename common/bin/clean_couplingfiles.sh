cd /scratch/WEX
find . |grep grb2 |xargs rm -f
find . |grep FILE: |xargs rm -f

# Removing coupling files older than a day
echo "Removing coupling files older than a day"
find . -mtime +0  |grep met_em |xargs rm -f
