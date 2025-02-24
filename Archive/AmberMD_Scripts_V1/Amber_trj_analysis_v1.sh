#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will help analysising the trajectory"
    echo "Use the following flags to run the script"
	echo "-p = Name of the protein without file extension"
	echo "-u = Name of the ligand without file extension"
	echo "-R = Starting residue no. of Receptor"
	echo "-r = Ending residue no. of Receptor"
	echo "-L = Starting residue no. of Ligand"
	echo "-l = Ending residue no. of Ligand"
	echo "-n = Name of the trajectory with file extension (.nc or .mdcrd)"
	echo "-T = Starting frame of Trajectory"
	echo "-t = Ending frame of Trajectory"
    echo ""
    echo "Usage: $0 -R <recstart> -r <recend> -L <ligstart> -l <ligend> -n <trajname> -T <trjstart> -t <trjend>"
    echo ""
    echo "Example: $0 -R 1 -r 569 -L 570 -l 570 -n prod1.nc -T 20000 -t 25000"
    echo "The analysis will be done based on the inputs from the flags"
    echo ""
    exit
fi

while getopts R:r:L:l:n:T:t: flag
do
	case "${flag}" in
		R) recstart=${OPTARG};;
		r) recend=${OPTARG};;
		L) ligstart=${OPTARG};;
		l) ligend=${OPTARG};;
		n) traj=${OPTARG};;
		T) trjstart=${OPTARG};;
		t) trjend=${OPTARG};;
	esac
done

echo "Protein Start: $recstart";
echo "Protein End: $recend";
echo "Ligand Start: $ligstart";
echo "Ligand End: $ligend";
echo "Name of the Trajectory: $traj";
echo "Trajectory Start: $trjstart";
echo "Trajectory End: $trjend";
echo "**************************************************";

# Removing exisiting files to avoid duplication
rm analysis.in;
rm exttraj.in;
rm exttraj_wat.in;

# Basic Trajectory Analysis
echo "trajin $traj $trjstart $trjend 1" >> analysis.in;
echo "reference equil1.rst" >> analysis.in;
echo "center :$recstart-$ligend" >> analysis.in;
echo "rms reference out protein-rmsd.agr :$recstart-$recend,@CA,C,N,O" >> analysis.in;
echo "rms reference out c-alpha-rmsd.agr :$recstart-$recend,@CA" >> analysis.in;
echo "rms reference out lig-rmsd.agr :$ligstart nofit" >> analysis.in;
echo "atomicfluct out rmsf.agr @C,CA,N byres" >> analysis.in;
echo "radgyr :$recstart-$recend&!(@H=) out RoG.agr mass nomax" >> analysis.in;

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

# Extraction of Trajectory Stripping Water and Ions
echo "trajin $traj $trjstart $trjend 10" >> exttraj.in;
echo "reference equil1.rst" >> exttraj.in;
echo "center :$recstart-$ligend" >> exttraj.in;
echo "strip :Na+" >> exttraj.in;
echo "strip :Cl-" >> exttraj.in;
echo "strip :WAT" >> exttraj.in;
echo "trajout traj.pdb pdb append" >> exttraj.in;

cpptraj -p com-sol1.prmtop -i exttraj.in;

echo "**************************************************";
echo "Trajectory extraction is done successfully!";
echo "**************************************************";

# Extraction of Trajectory with 20 WAT around ligand
echo "trajin $traj $trjstart $trjend 10" >> exttraj_wat.in;
echo "reference equil1.rst" >> exttraj_wat.in;
echo "center :$recstart-$ligend" >> exttraj_wat.in;
echo "autoimage" >> exttraj_wat.in;
echo "closest 20 :$ligstart first" >> exttraj_wat.in;
echo "strip :Na+" >> exttraj_wat.in;
echo "strip :Cl-" >> exttraj_wat.in;
echo "trajout traj_20WAT.pdb pdb append" >> exttraj_wat.in;

cpptraj -p com-sol1.prmtop -i exttraj_wat.in;

echo "**************************************************";
echo "Trajectory with 20 WAT is extracted successfully!";
echo "**************************************************";