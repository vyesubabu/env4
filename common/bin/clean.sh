#!/bin/bash

rm -f rsl.*
rm -f slurm*
rm -f .expected* .process*
rm -f unipost*.slurm
rm -rf postprd.*

echo "Clean wrfout + wrfprs files ?"
read answer
if [ "$answer" == "Y" ]; then
#	rm -f wrf[biop]*
	rm -f wrf[op]*
fi
echo "Clean more files (wrfinput, wrfbdy...)?"
read answer
if [ "$answer" == "Y" ]; then
	rm -f wrf[biop]*
fi
exit 0
