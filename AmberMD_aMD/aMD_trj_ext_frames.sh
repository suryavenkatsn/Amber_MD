#!/bin/bash

# Frame calculation
x=50; # Frames per ns
y=500000; # Time Steps per ns
ts=250000000;

tp=$((ts / y));
z=$((tp / 5));


# Current directory
dir=$(pwd | grep -o '[^/]*$')

# # Residue No. Assignment and timestep calculation
# lignum=$(awk '/UNK/ { print $5;exit; }' com.pdb);
# recend=$((lignum - 1))

# Extraction of particular frame from the input Trajectory

if [ -f frames_$tp/ ];then
	rm -r frames_$tp/;
fi

mkdir frames_$tp

while [ $z -gt 0 ]
do
	ns=$((z * 5));
	frame=$((ns * x));
	echo "***********************************************************";
	echo "Name of the Trajectory: prod_amd.nc";
	echo "Time period (ns): $ns";
	echo "Frame No.: $frame";
	echo "***********************************************************";


	rm extframe_$ns.in;

	echo "trajin prod_amd.nc $frame $frame 1" >> extframe_$ns.in;
	echo "reference com-sol1.inpcrd" >> extframe_$ns.in;
	echo "center :1-487" >> extframe_$ns.in;
	echo "autoimage" >> extframe_$ns.in;
	echo "closest 30 :487 first" >> extframe_$ns.in;
	echo "strip :Na+" >> extframe_$ns.in;
	echo "strip :Cl-" >> extframe_$ns.in;
	echo "trajout $dir"_ns_"$ns.pdb" >> extframe_$ns.in;

	cpptraj -p com-sol1.prmtop -i extframe_$ns.in > extframe_$ns.out;

	echo "***********************************************************";
	echo "Extraction of frame at $ns ns - Done";
	echo "***********************************************************";

	z=$((z - 1));
done

mv $dir*.pdb frames_$tp/