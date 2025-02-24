#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will create input and sh file for mmpbsa calculation from the input trajectory"
    echo "Use the following flags to run the script"
	echo "-R = Starting residue no. of Receptor"
	echo "-r = Ending residue no. of Receptor"
	echo "-L = Starting residue no. of Ligand"
	echo "-l = Ending residue no. of Ligand"
	echo "-n = Name of the trajectory with file extension (.nc or .mdcrd)"
	echo "-T = Starting frame of Trajectory"
	echo "-t = Ending frame of Trajectory"
	echo "-I = Interval for snapshots from Trajectory"
	echo ""
    echo "Usage: $0 <step>"
    echo ""
    echo "Example: $0 -R 1 -r 569 -L 570 -l 570 -n step7_production.nc -T 20000 -t 25000 -I 100"
    echo "This will create input for mmpbsa calculation for ~ 50 snapshots from the trajectory"
    echo
    exit
fi

while getopts R:r:L:l:n:T:t:I:i: flag
do
	case "${flag}" in
 		R) recstart=${OPTARG};;
		r) recend=${OPTARG};;
		L) ligstart=${OPTARG};;
		l) ligend=${OPTARG};;
		n) traj=${OPTARG};;
		T) trjstart=${OPTARG};;
		t) trjend=${OPTARG};;
		I) interval=${OPTARG};;
	esac
done


echo "Protein Start: $recstart";
echo "Protein End: $recend";
echo "Ligand Start: $ligstart";
echo "Ligand End: $ligend";
echo "Name of the Trajectory: $traj";
echo "Trajectory Start: $trjstart";
echo "Trajectory End: $trjend";
echo "Interval: $interval";

echo "****************************************************";


# Remove exisiting files to avoid duplication
if [ -f mmpbsa_dc.in ];then
	rm mmpbsa_dc.in;
fi

if [ -f run_mmpbsa_dc.sh ];then
	rm run_mmpbsa_dc.sh;
fi

# Input for mmpbsa.py (Only GB decomposition)
echo "Per-residue GB decomposition" >> mmpbsa_dc.in;
echo "&general" >> mmpbsa_dc.in;
echo "   startframe=$trjstart, endframe=$trjend, interval=$interval, verbose=1," >> mmpbsa_dc.in;
echo "/" >> mmpbsa_dc.in;
echo "&gb" >> mmpbsa_dc.in;
echo "  igb=2, saltcon=0.100," >> mmpbsa_dc.in;
echo "/" >> mmpbsa_dc.in;
echo "&decomp" >> mmpbsa_dc.in;
echo "  idecomp=2, print_res=\"$recstart-$ligend\"" >> mmpbsa_dc.in;
echo "  dec_verbose=3," >> mmpbsa_dc.in;
echo "/" >> mmpbsa_dc.in;

x=$trjstart;
y=$trjend;
z=$interval;
r=$((y - x));
s=$((r / z));


echo "****************************************************";
echo "mmpbsa_dc.in is created successfully!";
echo "This input file can extract $s snapshots";
echo "****************************************************";


# Script to run mmpbsa.py (Only GB decomposition)

echo "#!/bin/sh" >> run_mmpbsa_dc.sh;
echo "\$AMBERHOME/bin/ante-MMPBSA.py -p step5_input.parm7 -c com1.prmtop -r rec1.prmtop -l UNK1.prmtop -s ':Na+,Cl-,WAT,PA,PC,OL' -n ':$ligend' --radii=mbondi3" >> run_mmpbsa_dc.sh;
echo "\$AMBERHOME/bin/MMPBSA.py -O -i mmpbsa_dc.in -o FINAL_RESULTS_MMPBSA1.dat -do FINAL_DECOMP_MMPBSA1.dat -sp step5_input.parm7 -cp com1.prmtop -rp rec1.prmtop -lp UNK1.prmtop -y $traj" >> run_mmpbsa_dc.sh;


echo "****************************************************";
echo "run_mmpbsa_dc.sh is created successfully!";
echo "****************************************************";
