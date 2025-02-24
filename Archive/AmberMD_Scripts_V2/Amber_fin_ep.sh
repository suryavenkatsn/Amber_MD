#!/bin/bash
if [ ! -n "$1" ];then
	echo "";
	echo "------------------------------------------------";
	echo "This script will perform equilibration of the solvated system, followed by production run";
	echo "Example: $0 0";
	echo "This will perform gpu based calculations at 0th gpu card";
	echo "------------------------------------------------";
	echo "";
	exit
fi

if [ -f densi.in ] && [ -f equil.in ] && [ -f equil1.in ] && [ -f prod.in ];then
        echo ""
		echo "***All input files are available for MD run***"		
else
        echo ""
		echo "***One or more input files are not available. Please ensure all the input files are in place before running this script***"
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

sander -O -i densi.in -o densi.out -p com-sol1.prmtop -c heat1.rst -r density.rst -x densi.nc -ref heat1.rst
pmemd.cuda -O -i equil.in -o equil.out -p com-sol1.prmtop -c density.rst -r equil.rst -x equil.nc -ref density.rst
pmemd.cuda -O -i equil1.in -o equil1.out -p com-sol1.prmtop -c equil.rst -r equil1.rst -x equil1.nc -ref equil.rst
pmemd.cuda -O -i prod.in -o prod1.out -p com-sol1.prmtop -c equil1.rst -r prod1.rst -x prod1.nc -ref equil1.rst
