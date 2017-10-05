#!/bin/bash


DOMAIN=`echo ${PWD##*/}`
TARLIST="WRFV3 WPS master.$DOMAIN.sh"

echo "Based on current directory, the DOMAIN Name is $DOMAIN"
echo "Is that ok? [Y/N]"
read answer

if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
  
  echo "Tarring the files..."
  tar cvfz $DOMAIN.tgz $TARLIST

else
  echo "Please provide a new name for the archive file... SOMETHING.tgz"
  read answer
  if [ -z "$answer" ]; then
        exit 1
  else
        tar cvfz $answer $TARLIST
  fi
fi

