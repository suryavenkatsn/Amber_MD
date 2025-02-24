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

r=$(awk '/RES/ { print $3 }' drug.in);
le=$(awk '/RES/ { print $3 }' watermin.in);
ls=$((r + 1));

ts1=$(awk '/nstlim/ { print $1 }' prod1.out | awk -F '[=,]' '{ print $2 }');

if [ ! -f prod_ext.in ];then
	ts=$ts1;
	echo $ts;
else
  ts2=$(awk '/nstlim/ { print $1 }' prod2.out | awk -F '[=,]' '{ print $2 }');
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
rm analysis.in;
rm exttraj.in;
rm exttraj_wat.in;

# Basic Trajectory Analysis
echo "trajin $1 0 $frame 1" >> analysis.in;
echo "reference equil1.rst" >> analysis.in;
echo "center :1-$le" >> analysis.in;
echo "rms reference out protein-rmsd.agr :1-$r,@CA,C,N,O" >> analysis.in;
echo "rms reference out c-alpha-rmsd.agr :1-$r,@CA" >> analysis.in;
echo "rms reference out lig-rmsd.agr :$ls nofit" >> analysis.in;
echo "atomicfluct out rmsf.agr @C,CA,N byres" >> analysis.in;
echo "radgyr :1-$r&!(@H=) out RoG.agr mass nomax" >> analysis.in;

cpptraj -p com-sol1.prmtop -i analysis.in > analysis.out;

echo "**************************************************";
echo "Trajectory Analysis is done successfully!";
echo "**************************************************";

# Conversion of .agr files to .png files
xmgrace -nxy protein-rmsd.agr -hdevice PNG -hardcopy -printfile protein-rmsd.png
xmgrace -nxy c-alpha-rmsd.agr -hdevice PNG -hardcopy -printfile c-alpha-rmsd.png
xmgrace -nxy lig-rmsd.agr -hdevice PNG -hardcopy -printfile lig-rmsd.png
xmgrace -nxy rmsf.agr -hdevice PNG -hardcopy -printfile rmsf.png
xmgrace -nxy RoG.agr -hdevice PNG -hardcopy -printfile RoG.png


# Extraction of Trajectory with 20 WAT around ligand
echo "trajin $1 0 $frame 10" >> exttraj_wat.in;
echo "reference equil1.rst" >> exttraj_wat.in;
echo "center :1-$le" >> exttraj_wat.in;
echo "autoimage" >> exttraj_wat.in;
echo "closest 20 :$ls first" >> exttraj_wat.in;
echo "strip :Na+" >> exttraj_wat.in;
echo "strip :Cl-" >> exttraj_wat.in;
echo "trajout traj_20WAT.pdb pdb append" >> exttraj_wat.in;

cpptraj -p com-sol1.prmtop -i exttraj_wat.in > exttraj_wat.out;

echo "**************************************************";
echo "Trajectory with 20 WAT is extracted successfully!";
echo "**************************************************";
