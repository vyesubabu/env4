TEXT2BANNER="$*"

if  [ -z "$COMMON_HOME" ]; then
	COMMON_HOME=/ecfshared/v4.0/common
fi	

flf=$COMMON_HOME/share/cips_resources/fonts/big.flf 
$COMMON_HOME/bin/figlet -f $flf "$TEXT2BANNER"

