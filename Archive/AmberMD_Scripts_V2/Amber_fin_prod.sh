#!/bin/bash
if [ ! -n "$1" ];then
	echo "";
	echo "------------------------------------------------";
	echo "This script will perform production run";
	echo "Example: $0 0";
	echo "This will perform gpu based calculations at 0th gpu card";
	echo "------------------------------------------------";
	echo "";
	exit
fi

if [ ! -f prod.in ];then
        echo ""
		echo "***prod.in is not found***"
        echo ""
		exit
fi

ts=$(awk '/nstlim/ { print $1 }' prod.in | awk -F '[=,]' '{ print $2 }');


# Frame calculation
x=500; # Frames per ns
y=500000; # Time Steps per ns
tp=$((ts / y));
z=$((tp / 5));

echo "";
echo "**********************************************";
echo "Selected CUDA device for the current MD = $1";
echo "Time period of production run (ns): $tp";
echo "**********************************************";
echo "";

export CUDA_VISIBLE_DEVICES=$1

pmemd.cuda -O -i prod.in -o prod1.out -p com-sol1.prmtop -c equil1.rst -r prod1.rst -x prod1.nc -ref equil1.rst
