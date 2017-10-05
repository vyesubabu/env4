#!/bin/bash
set +x
DIRS2TAR="input out run bin resources lib module modules"

if [ "$1" == "FORCE" ]; then
	FORCED_ANSWER="Y"
fi
TASKNAME=`echo ${PWD##*/}`

echo "Based on current directory, the Task Name is $TASKNAME"
echo "Is that ok? [Y/N]"
if [ -z "$FORCED_ANSWER" ]; then
	read answer
else
	answer=$FORCED_ANSWER
fi
if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
  
  echo "Tarring the files..."
  FL=`find $DIRS2TAR | awk '!/.svn/'`
  tar cvfz $TASKNAME.tgz $FL --no-recursion 
#  tar cvfz $TASKNAME.tgz $DIRS2TAR

else
  echo "Please provide a new name for the archive file... SOMETHING.tgz"
  read answer
  if [ -z "$answer" ]; then
        exit 1
  else
  	FL=`find $DIRS2TAR | awk '!/.svn/'`
  	tar  cvfz $answer $FL --no-recursion
        #tar cvfz $answer $DIRS2TAR
  fi
fi

