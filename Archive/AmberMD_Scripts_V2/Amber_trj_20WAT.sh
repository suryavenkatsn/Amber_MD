#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will help analysing the input trajectory"
    echo "Use the following flags to run the script"
	  echo "-n = Name of the trajectory with file extension (.nc or .mdcrd)"
	  echo ""
    echo "Usage: $0 <trajname>"
    echo ""
    echo "Example: $0 prod1.nc "
    echo "This will generate stripped pdb file from the input trajectory"
    echo ""
    exit
fi


r=$(awk '/RES/ { print $3 }' drug.in);
le=$(awk '/RES/ { print $3 }' watermin.in);
ls=$((r + 1));

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
frame=$((tp * x));

echo "Protein Start: 1";
echo "Protein End: $r";
echo "Ligand Start: $ls";
echo "Ligand End: $le";
echo "Name of the Trajectory: $1";
echo "Trajectory Start: 0";
echo "Trajectory End: $frame";
echo "**************************************************";

# Removing exisiting files to avoid duplication
rm exttraj_wat.in;

# Extraction of Trajectory with 20 WAT around ligand
echo "trajin $1 0 $frame 10" >> exttraj_wat.in;
echo "reference equil1.rst" >> exttraj_wat.in;
echo "center :1-$le" >> exttraj_wat.in;
echo "autoimage" >> exttraj_wat.in;
echo "closest 20 :$ls first" >> exttraj_wat.in;
echo "strip :Na+" >> exttraj_wat.in;
echo "strip :Cl-" >> exttraj_wat.in;
echo "trajout traj_20WAT.pdb pdb append" >> exttraj_wat.in;

cpptraj -p com-sol1.prmtop -i exttraj_wat.in;

echo "**************************************************";
echo "Trajectory with 20 WAT is extracted successfully!";
echo "**************************************************";
