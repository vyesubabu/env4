#!/bin/bash 
. $COMMON_HOME/bin/cips_bash_functions.sh

## For IDL RunTime tasks: uncomment the following when moving to integration
## export DISPLAY=localhost:66

#############################################
#   I /  GET DATA FROM CIPS
#############################################
$COMMON_HOME/bin/cips_get.py -i $TASK_RESOURCES/myxml.xml -o $TASK_IN/input.grb --mode url --debug

#testing invalid input : invalid if either no files are found or 
# if all files are empty files, it will exit with code 1
invalid_input_in_dir $TASK_IN 

#############################################
#   II /  PROCESS THE DATA 
#############################################

cd $TASK_RUN

echo $PWD
ls -lrt
touch output_example
mv output_example $TASK_OUT

#############################################
#   III /  SEND THE OUTPUT TO TRANSMET
#############################################

cd $TASK_OUT

## Sending output data through its TRANSMET Headers
HEADER="SOME_HEADER_ASK_CIPS_ADMINS"
$COMMON_HOME/bin/cips_send.py --mode transmet-header  --header $HEADER --files output_example
sendok=`echo $?`
if [ $sendok -eq 1 ] ; then
        echo " ";
        echo "At least one of the file transfers did not work";
        echo "ABORTING!"
        smsabort
fi
