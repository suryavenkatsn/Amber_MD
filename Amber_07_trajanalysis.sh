#!/bin/bash
if [ ! -n "$1" ];then
	echo ""
	echo "Example: $0 20 prod1.nc ligand.mol2"
	echo ""
	exit
fi

# TimeStep Calculation
traj=$2
a=500; # Frames per ns
x=500000;  # Time Steps per ns
ns=$1;
ts=$((x * ns));
tp=$((ts / x));
trajend=$((tp * a));

lignum=$(awk '/UNK/ { print $5;exit; }' com.pdb);
comstart=1
comend=$(tail -3 com.pdb | awk '{print $5}')

# Basic Trajectory Analysis
printf "trajin ${traj} 0 ${trajend} 1
reference equil1.rst
center :1-${comend}
rms reference out protein-rmsd.agr :1-${comend},@CA,C,N,O
rms reference out c-alpha-rmsd.agr :1-${comend},@CA
rms reference out lig-rmsd.agr :${lignum} nofit
atomicfluct out rmsf.agr @C,CA,N byres
radgyr :1-${comend}&!(@H=) out RoG.agr mass nomax
" > analysis.in;

cpptraj -p com-sol1.prmtop -i analysis.in > analysis.out;

# Conversion of .agr files to .png files

for file in *.agr; do
    if [ -f "${file}" ]; then
        echo "Processing file: ${file}"
        fname=$(echo "${file}" | awk -F '[.]' '{ print $1 }')
        gracebat -nxy ${file} -hdevice PNG -hardcopy -printfile ${fname}.png
    fi
done
