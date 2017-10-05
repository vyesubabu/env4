#!/bin/bash
#
# This script genrates a list of headers for TRANSMET implementation 
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTEUR: REMI MONTROTY                                   Jan, 01  2011     #
#                                                                             #
#   VERSION :								      #
#	* v1.0								  # 
#		-							  #
#									  #
#   LATEST MODIFICATIONS :					  	#
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  generate_headers.sh COSMO KNEW0140 1 72
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
MODEL=$1
GRID=$2
INTERVAL=$3
RANGEMAX=$4
SET=$5
if [ -z "$MODEL" ] || [ -z "$GRID" ] || [ -z "$INTERVAL" ] || [ -z "$RANGEMAX" ] || [ -z "$SET" ]; then
	echo "MODEL, GRID, OUTPUT_INTERVAL or RANGEMAX unset.. Please use : $0 MODEL GRIDNAME OUTPUT_INTERVAL RANGEMAX SET_TYPE"
	exit 1
fi
DOMAIN=`echo $GRID | cut -c1-4`
RESOLUTION=`echo $GRID | cut -c5-8`
#SET=FULL
PROVIDER=CIPS
TARGET=CIPS

#echo "Default Set = $SET. Is it ok? Press N for ARCHIVE set"
#read answer
#if [ "$answer" == "N" ] || [ "$answer" == "n" ]; then
#	SET=ARCHIVE
#fi

case $MODEL in 
	COSMO) 	T1=Y;  	C2=C ;;
	GME) 	T1=Y;  	C2=D ;;
	GFS) 	T1=Y;  	C2=G ;;
	HRM)  	T1=Y; 	C2=H ;;
	WRF)  	T1=Y;	C2=W ;;
	*) echo "Unknown model" ; exit 1 ;;
esac
case $DOMAIN in 
	AFRI) A1=P ;;
	KNEW) A1=O ;;
	KOLD) A1=M ;;
	*) echo "Unknown domain" ; exit 1 ;;
esac
case $RESOLUTION in 
	0500) 
		case $MODEL in
			GFS) C4=A;;
			*) echo "unknown model $MODEL at resolution $RESOLUTION" ; exit  1;;
		esac ;;
	0300) 
		case $MODEL in
			GME) C4=A;;
			*) echo "unknown model $MODEL at resolution $RESOLUTION" ; exit  1;;
		esac ;;
	0140) 
		case $MODEL in
			COSMO) C4=B;;
			HRM) C4=A;;
			*) echo "unknown model $MODEL at resolution $RESOLUTION" ; exit  1;;
		esac ;;
	0070) 
		case $MODEL in
			COSMO) C4=A;;
			WRF) C4=A;;
			*) echo "unknown model $MODEL at resolution $RESOLUTION" ; exit 1;;
		esac ;;
	*) echo "Unknown resolution" ; exit 1 ;;
esac
case $TARGET in 
	CIPS) C3=C ;;
	*) echo "Unknown target" ; exit 1 ;;
esac
case $PROVIDER in 
	CIPS) C1=Q ;;
	*) echo "Unknown provider" ; exit 1 ;;
esac
case $SET in 
	FULL) T2=X ;;
	ARCHIVE) T2=S ;;
	*) echo "Unknown Set" ; exit 1 ;;
esac

for RANGE in `seq  0 $INTERVAL $RANGEMAX`; do
	if [ $RANGE -lt 100 ]; then
		A2=R
	elif  [ $RANGE -lt 200 ]; then
		A2=S
	elif  [ $RANGE -lt 300 ]; then
		A2=T
	else
		echo "too large value for RANGE=$RANGE"
		exit 1
	fi
	range=`echo $RANGE | awk '{printf("%.2d\n", $1%100)}'`
	ii=$range

	COMMENT="$MODEL Forecast for Range $range, on domain $DOMAIN"
	COMMENT=""
	echo ${T1}${T2}${A1}${A2}${ii}${C1}${C2}${C3}${C4}" $COMMENT"

done



