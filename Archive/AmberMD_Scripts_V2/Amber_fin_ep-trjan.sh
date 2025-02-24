#!/bin/bash
if [ ! -n "$1" ];then
    echo "";
    echo "---------------------------------------------------------";
    echo "This script will perform equilibration of the solvated system, followed by production run";
    echo "Example: $0 0";
    echo "This will perform gpu based calculations at 0th gpu card";
    echo "---------------------------------------------------------";
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


sleep 1m;

if [ ! -e prod1.nc ];then
    echo "";
    echo "---------------------------------------------------------";
    echo "Further Analysis can't be done as prod1.nc is not found";
    echo "---------------------------------------------------------";
    echo "";
    exit
fi

# Current directory
dir=$(pwd | grep -o '[^/]*$')

# Extraction of particular frame from the input Trajectory

while [ $z -gt 0 ]
do
	ns=$((z * 5));
	frame=$((ns * x));
	echo "***********************************************************";
	echo "Name of the Trajectory: prod1.nc";
	echo "Time period (ns): $ns";
	echo "Frame No.: $frame";
	echo "***********************************************************";

# Removing exisiting files to avoid duplication
	rm extframe_$ns.in;

	echo "trajin prod1.nc $frame $frame 1" >> extframe_$ns.in;
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



r=$(awk '/RES/ { print $3 }' drug.in);
le=$(awk '/RES/ { print $3 }' watermin.in);
ls=$((r + 1));

ts=$(awk '/nstlim/ { print $1 }' prod.in | awk -F '[=,]' '{ print $2 }');

# Frame calculation
x=500; # Frames per ns
y=500000; # Time Steps per ns
tp=$((ts / y));
frame=$((tp * x));

echo "Protein Start: 1";
echo "Protein End: $r";
echo "Ligand Start: $ls";
echo "Ligand End: $le";
echo "Name of the Trajectory: prod1.nc";
echo "Trajectory Start: 0";
echo "Trajectory End: $frame";
echo "**************************************************";

# Removing exisiting files to avoid duplication
rm analysis.in;
rm exttraj.in;
rm exttraj_wat.in;

# Basic Trajectory Analysis
echo "trajin prod1.nc 0 $frame 1" >> analysis.in;
echo "reference equil1.rst" >> analysis.in;
echo "center :1-$le" >> analysis.in;
echo "rms reference out protein-rmsd.agr :1-$r,@CA,C,N,O" >> analysis.in;
echo "rms reference out c-alpha-rmsd.agr :1-$r,@CA" >> analysis.in;
echo "rms reference out lig-rmsd.agr :$ls nofit" >> analysis.in;
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


# Extraction of Trajectory with 20 WAT around ligand
echo "trajin prod1.nc 0 $frame 10" >> exttraj_wat.in;
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