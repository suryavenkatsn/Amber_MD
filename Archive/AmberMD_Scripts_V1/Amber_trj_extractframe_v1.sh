#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will help extracting a particular frame from the trajectory"
    echo "Use the following flags to run the script"
	echo "-n = Name of the trajectory with file extension (.nc or .mdcrd)"
	echo "-f = Frame no. to extract"
    echo ""
    echo "Usage: $0 -n <trajname> -f <timeperiod>"
    echo ""
    echo "Example: $0 -n prod1.nc -f 20"
    echo "This will extract 10000th frame from the trajectory"
    echo ""
    exit
fi

while getopts n:f: flag
do
	case "${flag}" in
		n) traj=${OPTARG};;
		f) timeperiod=${OPTARG};;
	esac
done

# Frame calculation
x=500;
y=$timeperiod;
frame=$((x *y));

# Current directory
dir=$(pwd | grep -o '[^/]*$')

echo "***********************************************************";
echo "Name of the Trajectory: $traj";
echo "Time period (ns): $timeperiod";
echo "Frame No.: $frame";
echo "***********************************************************";

# Removing exisiting files to avoid duplication
rm extframe_$timeperiod.in;

# Extraction of particular frame from the input Trajectory
echo "trajin $traj $frame $frame 1" >> extframe_$timeperiod.in;
echo "reference com-sol1.inpcrd" >> extframe_$timeperiod.in;
echo "strip :Na+" >> extframe_$timeperiod.in;
echo "strip :Cl-" >> extframe_$timeperiod.in;
echo "strip :WAT" >> extframe_$timeperiod.in;
echo "trajout $dir"_ns_"$timeperiod.pdb" >> extframe_$timeperiod.in;

cpptraj -p com-sol1.prmtop -i extframe_$timeperiod.in;

echo "***********************************************************";
echo "Extraction of frame at $timeperiod ns is done successfully!";
echo "***********************************************************";