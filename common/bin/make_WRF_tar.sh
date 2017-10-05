#!/bin/bash


#WRFNAME=`echo ${PWD##*/}`
WRFNAME=WRF.tgz

TARLIST="wrf.tools.gcc44 output WPS WRFV3 UPPV0.5 geog bin"

echo "WRF tgz will be $WRFNAME"
echo "Is that ok? [Y/N]"
read answer

if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
  
  echo "Tarring the files..."
  tar cvfz $WRFNAME $TARLIST

else
  echo "Please provide a new name for the archive file... SOMETHING.tgz"
  read answer
  if [ -z "$answer" ]; then
        exit 1
  else
        tar cvfz $answer $TARLIST
  fi
fi

