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
    echo
    echo "Usage: $0 <step>"
    echo ""
    echo "Example: $0 -R 1 -r 569 -L 570 -l 570 -n  prod1.nc -T 20000 -t 25000 -I 100"
    echo "This will create input for mmpbsa calculation for ~ 50 snapshots from the trajectory"
    echo
    exit
fi

while getopts R:r:L:l:n:T:t:I: flag
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

if [ -f mmpbsa_per_res_decomp_gb.in ] && [ -f run_mmpbsa_decomp_gb.sh ];then
	rm mmpbsa_per_res_decomp_gb.in;
	rm run_mmpbsa_decomp_gb.sh;
fi

# Input for mmpbsa.py (Only GB decomposition)
echo "Per-residue GB decomposition" >> mmpbsa_per_res_decomp_gb.in;
echo "&general" >> mmpbsa_per_res_decomp_gb.in;
echo "   startframe=$trjstart, endframe=$trjend, interval=$interval, verbose=1," >> mmpbsa_per_res_decomp_gb.in;
echo "/" >> mmpbsa_per_res_decomp_gb.in;
echo "&gb" >> mmpbsa_per_res_decomp_gb.in;
echo "  igb=5, saltcon=0.100," >> mmpbsa_per_res_decomp_gb.in;
echo "/" >> mmpbsa_per_res_decomp_gb.in;
echo "&decomp" >> mmpbsa_per_res_decomp_gb.in;
echo "  idecomp=1, print_res=\"5; $recstart-$recend; $ligstart-$ligend\"" >> mmpbsa_per_res_decomp_gb.in;
echo "  dec_verbose=1," >> mmpbsa_per_res_decomp_gb.in;
echo "/" >> mmpbsa_per_res_decomp_gb.in;

x=$trjstart;
y=$trjend;
z=$interval;
r=$((y - x));
s=$((r / z));


echo "****************************************************";
echo "mmpbsa_per_res_decomp_gb.in is created successfully!";
echo "This input file can extract $s snapshots";
echo "****************************************************";

# Script to run mmpbsa.py (Only GB decomposition)

echo "#!/bin/sh" >> run_mmpbsa_decomp_gb.sh;
echo "\$AMBERHOME/bin/MMPBSA.py -O -i mmpbsa_per_res_decomp_gb.in -o FINAL_RESULTS_MMPBSA.dat -do FINAL_DECOMP_MMPBSA.dat -sp ../com-sol1.prmtop -cp ../com.prmtop -rp ../rec.prmtop -lp ../UNK.prmtop -y ../$traj" >> run_mmpbsa_decomp_gb.sh;

echo "****************************************************";
echo "run_mmpbsa_decomp_gb.sh is created successfully!";
echo "****************************************************";


mkdir mmpbsa_py
mv mmpbsa_per_res_decomp_gb.in run_mmpbsa_decomp_gb.sh mmpbsa_py/