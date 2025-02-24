#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will help extracting a particular frame from the trajectory"
    echo "Use the following flags to run the script"
	  echo "-n = Name of the trajectory with file extension (.nc or .mdcrd)"
	  echo ""
    echo "Usage: $0 <trajname>"
    echo ""
    echo "Example: $0 prod1.nc "
    echo "This will extract frames from the input trajectory"
    echo ""
    exit
fi

ts1=$(awk '/nstlim/ { print $1 }' prod.in | awk -F '[=,]' '{ print $2 }');

if [ ! -f prod_ext.in ];then
	ts=$ts1;
	echo $ts;
else
  ts2=$(awk '/nstlim/ { print $1 }' prod_ext.in | awk -F '[=,]' '{ print $2 }');
	ts=$((ts1 + ts2));
	echo $ts;
fi


# Frame calculation
x=500; # Frames per ns
y=500000; # Time Steps per ns
tp=$((ts / y));
z=$((tp / 5));

# Current directory
dir=$(pwd | grep -o '[^/]*$')

# Extraction of particular frame from the input Trajectory

while [ $z -gt 0 ]
do
	ns=$((z * 5));
	frame=$((ns * x));
	echo "***********************************************************";
	echo "Name of the Trajectory: $1";
	echo "Time period (ns): $ns";
	echo "Frame No.: $frame";
	echo "***********************************************************";

# Removing exisiting files to avoid duplication
	rm extframe_$ns.in;

	echo "trajin $1 $frame $frame 1" >> extframe_$ns.in;
	echo "reference com-sol1.inpcrd" >> extframe_$ns.in;
	echo "strip :Na+" >> extframe_$ns.in;
	echo "strip :Cl-" >> extframe_$ns.in;
	echo "strip :WAT" >> extframe_$ns.in;
	echo "trajout $dir"_ns_"$ns.pdb" >> extframe_$ns.in;

	cpptraj -p com-sol1.prmtop -i extframe_$ns.in;

	echo "***********************************************************";
	echo "Extraction of frame at $ns ns is done successfully!";
	echo "***********************************************************";

	z=$((z - 1));
done
