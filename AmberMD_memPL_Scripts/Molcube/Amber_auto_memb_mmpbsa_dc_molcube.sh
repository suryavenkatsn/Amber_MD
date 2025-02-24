#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
	echo "Example: $0 20";
	echo
    exit
fi

# Current directory
if [ ! -f dir.txt ];then
	pwd | grep -o '[^/]*' > dir.txt
	dir=$(tac dir.txt | head -n 2 | sed -n 2p)
else
	rm dir.txt
	pwd | grep -o '[^/]*' > dir.txt
	dir=$(tac dir.txt | head -n 2 | sed -n 2p)
fi


# TimeStep Calculation
x=500000; # timestep per ns
y=$1;
ts=$((x * y)); # timestep

# Frame calculation
a=500; # Frames per ns
tp=$((ts / x)); # time period
z=$((tp / 5));

# Traj Start and End for MMPBSA

pbsaend=$((y * a))
pbsastart=$((pbsaend * 80 / 100))
int=$(((pbsaend - pbsastart) / 50 ))


# Residue No. Assignment and timestep calculation
lignum=$(awk '/RES/ { print $3;exit; }' step2.0_minimization.mdin)
recstart=1
recend=`expr $lignum - $recstart`


if [ ! -e step3_production.nc ];then
    echo "";
    echo "----------------------------------------------------------------------";
    echo "| Further Analysis can't be done as step3_production.nc is not found |";
    echo "----------------------------------------------------------------------";
    echo "";
    exit
fi


echo "Protein Start: 1";
echo "Protein End: $recend";
echo "Ligand Number: $lignum";
echo "Name of the Trajectory: step3_production.nc";
echo "Trajectory Start: $pbsastart";
echo "Trajectory End: $pbsaend";
echo "int: $int";
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
echo "   startframe=$pbsastart, endframe=$pbsaend, interval=$int, verbose=1," >> mmpbsa_dc.in;
echo "/" >> mmpbsa_dc.in;
echo "&gb" >> mmpbsa_dc.in;
echo "  igb=2, saltcon=0.100," >> mmpbsa_dc.in;
echo "/" >> mmpbsa_dc.in;
echo "&decomp" >> mmpbsa_dc.in;
echo "  idecomp=2, print_res=\"1-$lignum\"" >> mmpbsa_dc.in;
echo "  dec_verbose=3," >> mmpbsa_dc.in;
echo "/" >> mmpbsa_dc.in;

l=$pbsastart;
m=$pbsaend;
n=$int;
r=$((m - l));
s=$((r / n));

# Script to run mmpbsa.py (Only GB decomposition)

echo "#!/bin/sh" >> run_mmpbsa_dc.sh;
echo "\$AMBERHOME/bin/ante-MMPBSA.py -p ../step1_input.parm7 -c com1.prmtop -r rec1.prmtop -l UNK1.prmtop -s ':Na+,Cl-,WAT,PA,PC,OL' -n ':$lignum' --radii=mbondi3" >> run_mmpbsa_dc.sh;
echo "\$AMBERHOME/bin/MMPBSA.py -O -i mmpbsa_dc.in -o FINAL_RESULTS_MMPBSA_$y.dat -do FINAL_DECOMP_MMPBSA_$y.dat -sp ../step1_input.parm7 -cp com1.prmtop -rp rec1.prmtop -lp UNK1.prmtop -y ../step3_production.nc" >> run_mmpbsa_dc.sh;


echo "****************************************************";
echo "mmpbsa_dc.in is created successfully!";
echo "run_mmpbsa_dc.sh is created successfully!";
echo "This input file can extract $s snapshots";
echo "****************************************************";

mkdir mmpbsa_py_$y
mv mmpbsa_dc.in run_mmpbsa_dc.sh mmpbsa_py_$y/

cd  mmpbsa_py_$y/

sh ./run_mmpbsa_dc.sh

cd ../

