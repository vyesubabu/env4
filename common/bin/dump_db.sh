#!/bin/bash

day=`date -u +%Y%m%d`
database=portail
user=admin_cips
SAVEDIR=/tmp
OUTFILE=$SAVEDIR/$day-$database.dump.sql


echo "Dumping Postgres DB $database to $OUTFILE"
pg_dump -U $user $database > $OUTFILE

#pg_dump -U admin_cips -c -d $database -F c -f $SAVEDIR/dump-$database-$day.sql 
