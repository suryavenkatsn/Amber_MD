#!/bin/bash
if [ ! -n "$1" ];then
	echo "Usage: $0 -t <trajectory>"
	echo ""
	echo "Example: $0 -t prod1.nc"
	echo ""
	exit
fi

while getopts t: flag
do
	case "${flag}" in
		t) traj=${OPTARG};;
	esac
done

# Frame calculation
x=500; # Frames per ns
y=500000; # Time Steps per ns

if [ ! -e prod2.out ]; then
	ts=$(awk '/nstlim/ { print $1 }' prod1.out | awk -F '[=,]' '{ print $2 }');
else
	ts1=$(awk '/nstlim/ { print $1 }' prod1.out | awk -F '[=,]' '{ print $2 }');
	ts2=$(awk '/nstlim/ { print $1 }' prod2.out | awk -F '[=,]' '{ print $2 }');
	ts=$((ts1 + ts2));
fi

tp=$((ts / y));
z=$((tp / 5));


if [ ! -e $traj ];then
    echo "";
    echo "---------------------------------------------------------";
    echo "Analysis can't be done as $traj is not found";
    echo "---------------------------------------------------------";
    echo "";
    exit
fi

# Current directory
dir=$(pwd | grep -o '[^/]*$')

# Residue No. Assignment and timestep calculation
lignum=$(awk '/UNK/ { print $5;exit; }' com.pdb);
recend=$((lignum - 1))

# Extraction of particular frame from the input Trajectory

if [ -f frames_$tp/ ];then
	rm -r frames_$tp/;
fi

mkdir frames_$tp



while [ $z -gt 0 ]
do
	ns=$((z * 5));
	frame=$((ns * x));
	echo "***********************************************************";
	echo "Name of the Trajectory: $traj";
	echo "Time period (ns): $ns";
	echo "Frame No.: $frame";
	echo "***********************************************************";


	rm extframe_$ns.in;

	echo "trajin $traj $frame $frame 1" >> extframe_$ns.in;
	echo "reference com-sol1.inpcrd" >> extframe_$ns.in;
	echo "center :1-$lignum" >> extframe_$ns.in;
	echo "autoimage" >> extframe_$ns.in;
	echo "closest 30 :$lignum first" >> extframe_$ns.in;
	echo "strip :Na+" >> extframe_$ns.in;
	echo "strip :Cl-" >> extframe_$ns.in;
	echo "trajout $dir"_ns_"$ns.pdb" >> extframe_$ns.in;

	cpptraj -p com-sol1.prmtop -i extframe_$ns.in > extframe_$ns.out;

	echo "***********************************************************";
	echo "Extraction of frame at $ns ns - Done";
	echo "***********************************************************";

	z=$((z - 1));
done

mv $dir*.pdb frames_$tp/




# Frame calculation
a=500; # Frames per ns
b=500000; # Time Steps per ns
tp=$((ts / b));
frame=$((tp * a));

echo "Protein Start: 1";
echo "Protein End: $recend";
echo "Ligand No.: $lignum";
echo "Name of the Trajectory: $traj";
echo "Trajectory Start: 0";
echo "Trajectory End: $frame";
echo "**************************************************";

# Removing exisiting files to avoid duplication
if [ -f analysis.in ];then
	rm analysis.in;
fi 

if [ -f exttraj_wat.in ];then
	rm exttraj_wat.in;
fi 

if [ -f conv_agr_png.sh ];then
	rm conv_agr_png.sh;
fi 

if [ -f graphs_$tp/ ];then
	rm -r graphs_$tp/;
fi

mkdir graphs_$tp

# Basic Trajectory Analysis
echo "trajin $traj 0 $frame 1" >> analysis.in;
echo "reference equil1.rst" >> analysis.in;
echo "center :1-$lignum" >> analysis.in;
echo "rms reference out protein-rmsd.agr :1-$recend,@CA,C,N,O" >> analysis.in;
echo "rms reference out c-alpha-rmsd.agr :1-$recend,@CA" >> analysis.in;
echo "rms reference out lig-rmsd.agr :$lignum nofit" >> analysis.in;
echo "atomicfluct out rmsf.agr @C,CA,N byres" >> analysis.in;
echo "radgyr :1-$recend&!(@H=) out RoG.agr mass nomax" >> analysis.in;

cpptraj -p com-sol1.prmtop -i analysis.in > analysis.out;

echo "";
echo "Trajectory Analysis - Done";

# Conversion of .agr files to .png files
echo "xmgrace -nxy protein-rmsd.agr -hdevice PNG -hardcopy -printfile protein-rmsd.png" >> conv_agr_png.sh
echo "xmgrace -nxy c-alpha-rmsd.agr -hdevice PNG -hardcopy -printfile c-alpha-rmsd.png" >> conv_agr_png.sh
echo "xmgrace -nxy lig-rmsd.agr -hdevice PNG -hardcopy -printfile lig-rmsd.png" >> conv_agr_png.sh
echo "xmgrace -nxy rmsf.agr -hdevice PNG -hardcopy -printfile rmsf.png" >> conv_agr_png.sh
echo "xmgrace -nxy RoG.agr -hdevice PNG -hardcopy -printfile RoG.png" >> conv_agr_png.sh

sh ./conv_agr_png.sh

if [ -f md_graphs.py ];then
	python md_graphs.py;
fi

echo "Conversion of .agr files to .png - Done"; 

mv protein-rmsd.agr c-alpha-rmsd.agr lig-rmsd.agr rmsf.agr RoG.agr conv_agr_png.sh  graphs_$tp/
mv protein-rmsd.png c-alpha-rmsd.png lig-rmsd.png rmsf.png RoG.png graphs_$tp/

if [ -f traj_analysis.pptx ];then
	mv traj_analysis.pptx graphs_$tp/;
	mv graphs_$tp/traj_analysis.pptx graphs_$tp/traj_analysis_$dir.pptx
fi

# Extraction of Trajectory with 20 WAT around ligand

if [ -f exttraj_$tp/ ];then
	rm -r exttraj_$tp/;
fi

mkdir exttraj_$tp

echo "trajin $traj 0 $frame 10" >> exttraj_wat.in;
echo "reference equil1.rst" >> exttraj_wat.in;
echo "center :1-$lignum" >> exttraj_wat.in;
echo "autoimage" >> exttraj_wat.in;
echo "closest 30 :$lignum first" >> exttraj_wat.in;
echo "strip :Na+" >> exttraj_wat.in;
echo "strip :Cl-" >> exttraj_wat.in;
echo "trajout traj_30WAT.pdb pdb append" >> exttraj_wat.in;

cpptraj -p com-sol1.prmtop -i exttraj_wat.in > exttraj_wat.out;


echo "Extraction of Trajectory with 30 WAT - Done";
echo "**************************************************";

mv traj_30WAT.pdb exttraj_$tp/

if [ -f hbond_$tp/ ];then
	rm -r hbond_$tp/;
fi

rm hbond_$tp.in
rm hbond_$tp.out


mkdir hbond_$tp

echo "trajin $traj 2000 $frame 1" >> hbond_$tp.in
echo "hbond contacts :1-$lignum avgout avg_$dir.dat series uuseries hbond.gnu nointramol" >> hbond_$tp.in
echo "go" >> hbond_$tp.in
echo "lifetime contacts[solutehb] out contacts-lifetime.dat" >> hbond_$tp.in
echo "go" >> hbond_$tp.in

cpptraj -p com-sol1.prmtop -i hbond_$tp.in > hbond_$tp.out

echo "Hbond calculation - Done";
echo "**************************************************";

mv avg_$dir.dat contacts-lifetime.dat crv.contacts-lifetime.dat hbond.gnu hbond_$tp/

# Traj Start and End for MMPBSA

pbsaend=$((tp * 500))
pbsastart=$((pbsaend * 80 / 100))
int=$(((pbsaend - pbsastart) / 50 ))

# Modification required from here
ligand=$(echo *.mol2 | awk -F '[.]' '{ print $1 }')
lignum=$(awk '/UNK/ { print $5;exit; }' com.pdb);
recstart=1
recend=$((lignum - 1))

echo "";
echo "****************************************************";
echo "Protein Start: $recstart";
echo "Protein End: $recend";
echo "Ligand Number: $lignum";
echo "Name of the Trajectory: $traj";
echo "Trajectory Start: $pbsastart";
echo "Trajectory End: $pbsaend";
echo "Interval: $int";
echo "----------------------------------------------------";

if [ -f mmpbsa_py_$tp/ ];then
	rm -r mmpbsa_py_$tp/;
fi

# Input for mmpbsa.py (Only GB decomposition)
echo "Per-residue GB decomposition" >> mmpbsa_per_res_decomp_gb.in;
echo "&general" >> mmpbsa_per_res_decomp_gb.in;
echo "   startframe=$pbsastart, endframe=$pbsaend, interval=$int, verbose=1," >> mmpbsa_per_res_decomp_gb.in;
echo "/" >> mmpbsa_per_res_decomp_gb.in;
echo "&gb" >> mmpbsa_per_res_decomp_gb.in;
echo "  igb=5, saltcon=0.100," >> mmpbsa_per_res_decomp_gb.in;
echo "/" >> mmpbsa_per_res_decomp_gb.in;
echo "&decomp" >> mmpbsa_per_res_decomp_gb.in;
echo "  idecomp=1, print_res=\"5; $recstart-$recend; $lignum\"" >> mmpbsa_per_res_decomp_gb.in;
echo "  dec_verbose=1," >> mmpbsa_per_res_decomp_gb.in;
echo "/" >> mmpbsa_per_res_decomp_gb.in;

i=$pbsastart;
j=$pbsaend;
k=$int;
r=$((j - i));
s=$((r / k));

# Script to run mmpbsa.py (Only GB decomposition)


echo "\$AMBERHOME/bin/MMPBSA.py -O -i mmpbsa_per_res_decomp_gb.in -o FINAL_RESULTS_MMPBSA.dat -do FINAL_DECOMP_MMPBSA.dat -sp ../com-sol1.prmtop -cp ../com.prmtop -rp ../rec.prmtop -lp ../UNK_$ligand/UNK.prmtop -y ../$traj" >> run_mmpbsa_decomp_gb.sh;

echo "----------------------------------------------------";
echo "mmpbsa_per_res_decomp_gb.in - Created";
echo "run_mmpbsa_decomp_gb.sh - Created";
echo "These input files perform free energy calculation on $s snapshots";
echo "****************************************************";

mkdir mmpbsa_py_$tp
mv mmpbsa_per_res_decomp_gb.in run_mmpbsa_decomp_gb.sh mmpbsa_py_$tp/

cd mmpbsa_py_$tp

sh ./run_mmpbsa_decomp_gb.sh

cd ../


if [ -f BE_$dir.csv ];then
	rm BE_$dir.csv;
fi

if [ -f PRED_$dir.csv ];then
	rm PRED_$dir.csv;
fi

if [ -f BE+PRED_$dir.csv ];then
	rm BE+PRED_$dir.csv;
fi


# Extract Binding energy value from FINAL result
echo "BindingEnergy Ligand dGbind Std.Err." | awk '{ print $1 "\n" $2 "," $3 "," $4 }' > H_BE_$dir.csv
be=$(grep -i 'DELTA TOTAL' ./mmpbsa_py_$tp/FINAL_RESULTS_MMPBSA.dat | awk '{ print $3 "," $5 }')
echo $dir $be | awk '{ print $1 "," $2 "," $3 }' > BE_$dir.csv

# Extract delta values of  per residue decomposition energies greater than -1.0 kcal/mol 
echo "PerResidueEnergyDecomposition Residue dGbind Std.Err." | awk '{ print $1 "\n" $2 "," $3 "," $4 }' > H_PRED_$dir.csv
awk '/^Total Energy Decomposition:/,/^Sidechain Energy Decomposition:/' ./mmpbsa_py_$tp/FINAL_DECOMP_MMPBSA.dat > temp.csv
sed -i '/Total Energy Decomposition/d' temp.csv
sed -i '/Sidechain Energy Decomposition/d' temp.csv
awk -F '[,]' '{ print $1 "\t" $18 "\t" $20 }' temp.csv > temp2.csv
sed -i '1,2d' temp2.csv
awk '$3 <= -1.0' temp2.csv | sort -k 3n > temp3.csv
awk -F '[\t]' '{print $1 "," $2 "," $3 }' temp3.csv > temp4.csv
sed -i '/2,$/d' temp4.csv
tail -n +1 temp4.csv | head -n -1 > temp && mv temp PRED_$dir.csv
d=$(echo "----------------------------------------------------------")
echo "$dir $d" | awk '{ print $1 "\n" $2 }' > BE+PRED_$dir.csv
cat H_BE_$dir.csv BE_$dir.csv H_PRED_$dir.csv PRED_$dir.csv >> BE+PRED_$dir.csv

rm temp.csv temp2.csv temp3.csv temp4.csv H_BE_$dir.csv H_PRED_$dir.csv

if [ -f plot_pred.py ];then
	rm plot_pred.py;
fi

# Creating python script for plotting PRED values

echo "import matplotlib.pyplot as plt" >> plot_pred.py
echo "import pandas as pd" >> plot_pred.py
echo "" >> plot_pred.py
echo "data = pd.read_csv('PRED_$dir.csv')" >> plot_pred.py
echo "" >> plot_pred.py
echo "df = pd.DataFrame(data)" >> plot_pred.py
echo "" >> plot_pred.py
echo "X = list(df.iloc[:, 0])" >> plot_pred.py
echo "Y = list(df.iloc[:, 1])" >> plot_pred.py
echo "" >> plot_pred.py
echo "plt.figure(figsize=(16,10))" >> plot_pred.py
echo "plt.bar(X, Y, color = 'g')" >> plot_pred.py
echo "plt.title('PRED - $dir', fontsize = 20)" >> plot_pred.py
echo "plt.xlabel('Residues')" >> plot_pred.py
echo "plt.ylabel('Free Energy Contribution (kcal/mol)')" >> plot_pred.py
echo "plt.savefig('pred_$dir.png',bbox_inches='tight',dpi=150)" >> plot_pred.py
echo "plt.close()" >> plot_pred.py

python3 plot_pred.py


if [ -f dg_$tp ];then
	rm -r dg_$tp;
	mkdir dg_$tp;
else
	mkdir dg_$tp;
fi



mv pred_$dir.png BE_$dir.csv PRED_$dir.csv BE+PRED_$dir.csv dg_$tp/