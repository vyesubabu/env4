function usage() {
    echo "usage: $0 VAR FILEIN {opt:FILEOUT}"
    exit 1
}


VAR=$1
FILEIN=$2
FILEOUT=$3

if [ -z "$VAR" ] || [ -z "$FILEIN" ]; then
    usage
fi

if [ -z "$FILEOUT" ];then
    FILEOUT=$VAR.nc
fi

ncks -v $VAR $FILEIN $FILEOUT
