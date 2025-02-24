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
    echo "This will generate graph, images and stripped pdb file from the input trajectory"
    echo ""
    exit
fi

r=$(awk '/RES/ { print $3 }' watermin.in);

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
echo "Name of the Trajectory: prod1.nc";
echo "Trajectory Start: 0";
echo "Trajectory End: $frame";
echo "**************************************************";

# Removing exisiting files to avoid duplication
rm analysis.in;
rm exttraj.in;
rm exttraj_wat.in;

# Basic Trajectory Analysis
echo "trajin $1 0 $frame 1" >> analysis.in;
echo "reference equil1.rst" >> analysis.in;
echo "center :1-$r" >> analysis.in;
echo "rms reference out protein-rmsd.agr :1-$r,@CA,C,N,O" >> analysis.in;
echo "rms reference out c-alpha-rmsd.agr :1-$r,@CA" >> analysis.in;
echo "atomicfluct out rmsf.agr @C,CA,N byres" >> analysis.in;
echo "radgyr :1-$r&!(@H=) out RoG.agr mass nomax" >> analysis.in;

cpptraj -p com-sol1.prmtop -i analysis.in;

echo "**************************************************";
echo "Trajectory Analysis is done successfully!";
echo "**************************************************";

# Conversion of .agr files to .png files
xmgrace -nxy protein-rmsd.agr -hdevice PNG -hardcopy -printfile protein-rmsd.png
xmgrace -nxy c-alpha-rmsd.agr -hdevice PNG -hardcopy -printfile c-alpha-rmsd.png
xmgrace -nxy lig-rmsd.agr -hdevice PNG -hardcopy -printfile lig-rmsd.png
xmgrace -nxy rmsf.agr -hdevice PNG -hardcopy -printfile rmsf.png
xmgrace -nxy RoG.agr -hdevice PNG -hardcopy -printfile RoG.png


# Extraction of Trajectory removing water molecules
echo "trajin prod1.nc 0 $frame 10" >> exttraj_wat.in;
echo "reference equil1.rst" >> exttraj_wat.in;
echo "center :1-$r" >> exttraj_wat.in;
echo "strip :Na+" >> exttraj_wat.in;
echo "strip :Cl-" >> exttraj_wat.in;
echo "strip :WAT" >> exttraj_wat.in;
echo "trajout traj.pdb pdb append" >> exttraj_wat.in;

cpptraj -p com-sol1.prmtop -i exttraj_wat.in;

echo "**************************************************";
echo "Trajectory is extracted successfully!";
echo "**************************************************";