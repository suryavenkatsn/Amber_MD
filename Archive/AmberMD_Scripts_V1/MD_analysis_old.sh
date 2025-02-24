#!/bin/bash
while getopts p:u:R:r:L:l:n:T:t: flag
do
	case "${flag}" in
		p) protein=${OPTATG};;
		u) ligand=${OPTARG};;
		R) recstart=${OPTARG};;
		r) recend=${OPTARG};;
		L) ligstart=${OPTARG};;
		l) ligend=${OPTARG};;
		n) traj=${OPTARG};;
		T) trjstart=${OPTARG};;
		t) trjend=${OPTARG};;
	esac
done
echo "Name of the Protein: $protein";
echo "Name of the Ligand: $ligand";
echo "Protein Start: $recstart";
echo "Protein End: $recend";
echo "Ligand Start: $ligstart";
echo "Ligand End: $ligend";
echo "Name of the Trajectory: $traj";
echo "Trajectory Start: $trjstart";
echo "Trajectory End: $trjend";

rm analysis.in
rm exttraj.in
rm exttraj_wat.in

$AMBERHOME

# Basic Analysis

echo "trajin $traj $trjstart $trjend 1" >> analysis.in
echo "reference equil1.rst" >> analysis.in
echo "rms reference out protein-rmsd.agr :$recstart-$recend,@CA,C,N,O" >> analysis.in
echo "rms reference out c-alpha-rmsd.agr :$recstart-$recend,@CA" >> analysis.in
echo "rms reference out lig-rmsd.agr :$ligstart nofit" >> analysis.in
echo "atomicfluct out rmsf.agr @C,CA,N byres" >> analysis.in
echo "radgyr :$recstart-$recend&!(@H=) out RoG.agr mass nomax" >> analysis.in

cpptraj -p com-sol1.prmtop -i analysis.in

# Extract Trajectory for Analysis

echo "trajin $traj $trjstart $trjend 10" >> exttraj.in
echo "reference equil1.rst" >> exttraj.in
echo "center :$recstart-$ligend" >> exttraj.in
echo "strip :Na+" >> exttraj.in
echo "strip :Cl-" >> exttraj.in
echo "strip :WAT" >> exttraj.in
echo "trajout traj.pdb pdb append" >> exttraj.in

cpptraj -p com-sol1.prmtop -i exttraj.in

# Extract Trajectory with 20 waters for Analysis

echo "trajin $traj $trjstart $trjend 10" >> exttraj_wat.in
echo "reference equil1.rst" >> exttraj_wat.in
echo "center :$recstart-$ligend" >> exttraj_wat.in
echo "autoimage" >> exttraj_wat.in
echo "closest 20 :$ligstart first" >> exttraj_wat.in
echo "strip :Na+" >> exttraj_wat.in
echo "strip :Cl-" >> exttraj_wat.in
echo "trajout traj_20WAT.pdb pdb append" >> exttraj_wat.in

cpptraj -p com-sol1.prmtop -i exttraj_wat.in

echo "MD_Analysis.sh is completed!"
