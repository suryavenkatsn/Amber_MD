#!/bin/bash
if [ ! -n "$1" ];then
	echo ""
	echo "Example: $0 20 <recend> <ligend>";
	echo "This will perform basic trajectory analysis for 20 ns Membrane MD simulation";
	echo
	exit
fi

# TimeStep Calculation
x=500000; # timestep per ns
y=$1;
ts=$((x * y)); # timestep

# Frame calculation
a=500; # Frames per ns
tp=$((ts / x)); # time period
z=$((tp / 5));

# Current directory
if [ ! -f dir.txt ];then
	pwd | grep -o '[^/]*' > dir.txt
	dir=$(tac dir.txt | head -n 2 | sed -n 2p)
else
	rm dir.txt
	pwd | grep -o '[^/]*' > dir.txt
	dir=$(tac dir.txt | head -n 2 | sed -n 2p)
fi

# Extraction of particular frame from the input Trajectory
if [ -f frames_$1/ ];then
	rm -r frames_$1/;
fi

mkdir frames_$1

while [ $z -gt 0 ]
do
	ns=$((z * 5));
	frame=$((ns * a));
	echo "***********************************************************";
	echo "Name of the Trajectory: ";
	echo "Time period (ns): $ns";
	echo "Frame No.: $frame";
	echo "***********************************************************";


	rm extframe_$ns.in;

	echo "trajin step7_production.nc $frame $frame 1" >> extframe_$ns.in;
	echo "reference step5_input.rst7" >> extframe_$ns.in;
	echo "strip :Na+" >> extframe_$ns.in;
	echo "strip :Cl-" >> extframe_$ns.in;
	echo "strip :WAT" >> extframe_$ns.in;
	echo "strip :POPE" >> extframe_$ns.in;
	# echo "strip :PC" >> extframe_$ns.in;
	# echo "strip :OL" >> extframe_$ns.in;
	echo "trajout $dir"_ns_"$ns.pdb" >> extframe_$ns.in;

	cpptraj -p step5_input.parm7 -i extframe_$ns.in > extframe_$ns.out;

	echo "***********************************************************";
	echo "Extraction of frame at $ns ns - Done";
	echo "***********************************************************";
	z=$((z - 1));
done

mv $dir*.pdb frames_$1/

### Needs modification

# Residue No. Assignment and timestep calculation
# lignum=$(awk '/RES/ { print $4;exit; }' step6.0_minimization.mdin)
# recend=$(awk '/RES/ { print $3;exit; }' step6.0_minimization.mdin)


# Frame calculation
frame=$((tp * a));

echo "Protein Start: 1";
echo "Protein End: $2";
# echo "Ligand No.: $lignum";
echo "Name of the Trajectory: step7_production.nc";
echo "Trajectory Start: 0";
echo "Trajectory End: $frame";
echo "**************************************************";

# Removing exisiting files to avoid duplication
if [ -f analysis.in ];then
	rm analysis.in;
fi 

if [ -f exttraj.in ];then
	rm exttraj.in;
fi 

if [ -f conv_agr_png.sh ];then
	rm conv_agr_png.sh;
fi 

if [ -f graphs_$1/ ];then
	rm -r graphs_$1/;
fi

mkdir graphs_$1

# Basic Trajectory Analysis
echo "trajin step7_production.nc 0 $frame 1" >> analysis.in;
echo "reference step6.6_equilibration.rst7" >> analysis.in;
echo "center :1-$2" >> analysis.in;
echo "rms reference out protein-rmsd.agr :1-$2,@CA,C,N,O" >> analysis.in;
echo "rms reference out c-alpha-rmsd.agr :1-$2,@CA" >> analysis.in;
# echo "rms reference out lig-rmsd.agr :$lignum nofit" >> analysis.in;
echo "atomicfluct out rmsf.agr @C,CA,N byres" >> analysis.in;
echo "radgyr :1-$2&!(@H=) out RoG.agr mass nomax" >> analysis.in;

cpptraj -p step5_input.parm7 -i analysis.in > analysis.out;

echo "";
echo "Trajectory Analysis - Done";

# Conversion of .agr files to .png files
echo "xmgrace -nxy protein-rmsd.agr -hdevice PNG -hardcopy -printfile protein-rmsd.png" >> conv_agr_png.sh
echo "xmgrace -nxy c-alpha-rmsd.agr -hdevice PNG -hardcopy -printfile c-alpha-rmsd.png" >> conv_agr_png.sh
# echo "xmgrace -nxy lig-rmsd.agr -hdevice PNG -hardcopy -printfile lig-rmsd.png" >> conv_agr_png.sh
echo "xmgrace -nxy rmsf.agr -hdevice PNG -hardcopy -printfile rmsf.png" >> conv_agr_png.sh
echo "xmgrace -nxy RoG.agr -hdevice PNG -hardcopy -printfile RoG.png" >> conv_agr_png.sh

sh ./conv_agr_png.sh

echo "Conversion of .agr files to .png - Done"; 

mv protein-rmsd.agr c-alpha-rmsd.agr rmsf.agr RoG.agr graphs_$1/
mv protein-rmsd.png c-alpha-rmsd.png rmsf.png RoG.png graphs_$1/

# Extraction of Trajectory with 20 WAT around ligand

if [ -f exttraj_$1/ ];then
	rm -r exttraj_$1/
fi

mkdir exttraj_$1

echo "trajin step7_production.nc 0 $frame 10" >> exttraj.in;
echo "reference step6.6_equilibration.rst7" >> exttraj.in;
echo "center :1-$3" >> exttraj.in;
echo "autoimage" >> exttraj.in;
# echo "closest 20 :$lignum first" >> exttraj.in;
echo "strip :Na+" >> exttraj.in;
echo "strip :Cl-" >> exttraj.in;
echo "strip :POPE" >> exttraj.in;
# echo "strip :PC" >> exttraj.in;
# echo "strip :OL" >> exttraj.in;
echo "trajout traj.pdb pdb append" >> exttraj.in;

cpptraj -p step5_input.parm7 -i exttraj.in > exttraj.out;

echo "Extraction of Trajectory - Done";
echo "**************************************************";

mv traj.pdb exttraj_$1/
