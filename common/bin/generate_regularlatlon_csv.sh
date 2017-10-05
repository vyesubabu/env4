SOUTH=-27
WEST=19
EAST=30
NORTH=-17

INC=$1
if [ -z "$INC" ]; then
    INC="0.25"
fi

OUTFILE=BOTS.$INC.csv
rm -f $OUTFILE

for lat in `seq $SOUTH $INC $NORTH`; do 
    for lon in `seq $WEST $INC $EAST`; do 
        echo "$lat ; $lon ; 1" >> $OUTFILE
    done ; 
done


cat $OUTFILE
