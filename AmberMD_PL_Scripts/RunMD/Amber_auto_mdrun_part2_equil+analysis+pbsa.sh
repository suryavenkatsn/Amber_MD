#!/bin/bash
if [ ! -n "$1" ];then
	echo ""
	echo "This script will run Minimization, Equilibration and Production MD for the modelled sytem"
	echo ""
	echo "Example: $0 20 0";
	echo "This will perform 20 ns MD simulation at 0th gpu card";
	echo
	exit
fi

# TimeStep Calculation
x=500000;
y=$1;
ts=$((x * y));

# Input generation for Minimization, Heating, Density, Equilibration and Production Run

lignum=$(awk '/UNK/ { print $5;exit; }' com.pdb);
recstart=1
recend=$((lignum - 1))

echo "";
echo "*****************___INPUTS___**********************";
echo "Protein Start: $recstart";
echo "Protein End: $recend";
echo "Ligand number: $lignum";
echo "Time period in nanoseconds (ns): $1";
echo "Calculated Time Step for $1 ns = $ts";
echo "***************************************************";
echo "----------------INPUT FILES CREATED----------------";

# # Input file for Water Minimization

# if [ -f watermin.in ];then
        # rm watermin.in
# fi

# echo "Minimize all hydrogens" >> watermin.in;
# echo " &cntrl" >> watermin.in;
# echo "  imin = 1," >> watermin.in;
# echo "  maxcyc = 5000," >> watermin.in;
# echo "  ncyc = 500," >> watermin.in;
# echo "  ntr = 1," >> watermin.in;
# echo "  cut = 10.0," >> watermin.in;
# echo "  saltcon=0.15," >> watermin.in;
# echo "/" >> watermin.in;
# echo "Keep protein and ligand fixed" >> watermin.in;
# echo "10.0" >> watermin.in;
# echo "RES $recstart $lignum" >> watermin.in;
# echo "END" >> watermin.in;
# echo "END" >> watermin.in;

# if [ -f "watermin.in" ];then
        # echo "watermin.in - Done"
# else
        # echo "watermin.in - Not Done"
# fi

# # Input file for Overall Minimization

# if [ -f min.in ];then
        # rm min.in
# fi

# echo "Unrestrained minimization, periodic system, xmin default" >> min.in;
# echo " &cntrl" >> min.in;
# echo "  imin = 1," >> min.in;
# echo "  ntmin = 1," >> min.in;
# echo "  maxcyc = 5000," >> min.in;
# echo "  ncyc = 500," >> min.in;
# echo "  ntb = 1,cut=10.0," >> min.in;
# echo "  saltcon=0.15," >> min.in;
# echo "/" >> min.in;
# echo "END" >> min.in;
# echo "END" >> min.in;

# if [ -f "min.in" ];then
        # echo "min.in - Done"
# else
        # echo "min.in - Not Done"
# fi


# # Input file for Temperature Equilibration

# if [ -f heat.in ];then
        # rm heat.in
# fi

# echo "heat" >> heat.in;
# echo " &cntrl" >> heat.in;
# echo "  imin=0,irest=0,ntx=1," >> heat.in;
# echo "  nstlim=100000,dt=0.002," >> heat.in;
# echo "  ntc=2,ntf=2," >> heat.in;
# echo "  ntt=3, gamma_ln = 0.2, ig = -1," >> heat.in;
# echo "  cut=10.0, ntb=1,ntr=1," >> heat.in;
# echo "  ntpr=5000, ntwx=5000," >> heat.in;
# echo "  ntwr=20000," >> heat.in;
# echo "  saltcon=0.15," >> heat.in;
# echo "  tempi=0.0, temp0=150.0," >> heat.in;
# echo "/" >> heat.in;
# echo "Keep protein and ligand fixed" >> heat.in;
# echo "5.0" >> heat.in;
# echo "RES $recstart $lignum" >> heat.in;
# echo "END" >> heat.in;
# echo "END" >> heat.in;

# if [ -f "heat.in" ];then
        # echo "heat.in - Done"
# else
        # echo "heat.in - Not Done"
# fi

# # Input file for second stage of Temperature Equilibration

# if [ -f heat1.in ];then
        # rm heat1.in
# fi

# echo "heat" >> heat1.in;
# echo " &cntrl" >> heat1.in;
# echo "  imin=0,irest=1,ntx=5," >> heat1.in;
# echo "  nstlim=100000,dt=0.002," >> heat1.in;
# echo "  ntc=2,ntf=2," >> heat1.in;
# echo "  ntt=3, gamma_ln = 0.2, ig = -1," >> heat1.in;
# echo "  cut=10.0, ntb=1,ntr=1," >> heat1.in;
# echo "  ntpr=5000, ntwx=5000," >> heat1.in;
# echo "  ntwr=20000," >> heat1.in;
# echo "  saltcon=0.15," >> heat1.in;
# echo "  tempi=150.0, temp0=300.0," >> heat1.in;
# echo "/" >> heat1.in;
# echo "Keep protein and ligand fixed" >> heat1.in;
# echo "5.0" >> heat1.in;
# echo "RES $recstart $lignum" >> heat1.in;
# echo "END" >> heat1.in;
# echo "END" >> heat1.in;

# if [ -f "heat1.in" ];then
        # echo "heat1.in - Done"
# else
        # echo "heat1.in - Not Done"
# fi

# # Input file for Density Equilibration

# if [ -f densi.in ];then
        # rm densi.in
# fi

# echo "density" >> densi.in;
# echo " &cntrl" >> densi.in;
# echo "  imin=0,irest=1,ntx=5," >> densi.in;
# echo "  ntc=2,ntf=2," >> densi.in;
# echo "  cut=10.0, ntb=2, ntr=1, nscm=1000," >> densi.in;
# echo "  ntpr=5000, ntwx=5000," >> densi.in;
# echo "  temp0=300.0,ntr=1,ioutfm=1,ntxo=2," >> densi.in;
# echo "  ntp = 1, pres0 = 1.0, taup =2.0," >> densi.in;
# echo "  nstlim = 100000, dt = 0.002," >> densi.in;
# echo "  saltcon=0.15," >> densi.in;
# echo "  ntt=3, gamma_ln = 0.2, ig = -1," >> densi.in;
# echo "/" >> densi.in;
# echo "Keep protein and ligand fixed" >> densi.in;
# echo "5.0" >> densi.in;
# echo "RES $recstart $lignum" >> densi.in;
# echo "END" >> densi.in;
# echo "END" >> densi.in;


# if [ -f "densi.in" ];then
        # echo "densi.in - Done"
# else
        # echo "densi.in - Not Done"
# fi

# # Input for Overall system equilbration

# if [ -f equil.in ];then
        # rm equil.in
# fi

# echo "equilibration" >> equil.in;
# echo " &cntrl" >> equil.in;
# echo "  imin=0,irest=1,ntx=5," >> equil.in;
# echo "  nstlim=100000,dt=0.002," >> equil.in;
# echo "  ntc=2,ntf=2,ioutfm=1,ntxo=2," >> equil.in;
# echo "  ntr=1,ntt=3, gamma_ln = 0.2, ig = -1," >> equil.in;
# echo "  cut=10.0, ntb=2, ntp=1, taup=2.0," >> equil.in;
# echo "  ntpr=5000, ntwx=5000,nscm=1000" >> equil.in;
# echo "  saltcon=0.15," >> equil.in;
# echo "  temp0=300.0, pres0 = 1.0," >> equil.in;
# echo "/" >> equil.in;
# echo "Keep protein and ligand fixed" >> equil.in;
# echo "2.0" >> equil.in;
# echo "RES $recstart $lignum" >> equil.in;
# echo "END" >> equil.in;
# echo "END" >> equil.in;

# if [ -f "equil.in" ];then
        # echo "equil.in - Done"
# else
        # echo "equil.in - Not Done"
# fi

# # Input for second stage of Overall system equilibration

# if [ -f equil1.in ];then
        # rm equil1.in
# fi

# echo "equilibration" >> equil1.in;
# echo " &cntrl" >> equil1.in;
# echo "  imin=0,irest=1,ntx=5," >> equil1.in;
# echo "  nstlim=50000, dt=0.002," >> equil1.in;
# echo "  ntc=2,ntf=2,ioutfm=1,ntxo=2," >> equil1.in;
# echo "  ntr=0,ntt=3, gamma_ln = 0.2, ig = -1," >> equil1.in;
# echo "  cut=10.0, ntb=2, ntp=1, taup=2.0," >> equil1.in;
# echo "  ntpr=5000, ntwx=5000,nscm=1000" >> equil1.in;
# echo "  saltcon=0.15," >> equil1.in;
# echo "  temp0=300.0, pres0 = 1.0," >> equil1.in;
# echo "/" >> equil1.in;
# echo "END" >> equil1.in;
# echo "END" >> equil1.in;

# if [ -f "equil1.in" ];then
        # echo "equil1.in - Done"
# else
        # echo "equil1.in - NotDone"
# fi

# # Input for Production Run

# if [ -f prod.in ];then
        # rm prod.in
# fi

# echo "Production at constant volume and temperature, $1 ns" >> prod.in;
# echo " &cntrl" >> prod.in;
# echo "  imin=0, irest=1, ntx=5," >> prod.in;
# echo "  ntpr=1000, ntwx=1000, ntwr=10000," >> prod.in;
# echo "  ntb=2, ntr=0," >> prod.in;
# echo "  ntp=1, pres0 = 1.0, taup = 2.0," >> prod.in;
# echo "  ntc=2, ntf=2," >> prod.in;
# echo "  cut=10.0, nscm=1000," >> prod.in;
# echo "  nstlim=$ts, dt=0.002," >> prod.in;
# echo "  saltcon=0.15," >> prod.in;
# echo "  temp0=300.0,ntt=3, gamma_ln = 0.2, ig = -1,ioutfm=1,ntxo=2," >> prod.in;
# echo "/" >> prod.in;
# echo "END" >> prod.in;
# echo "END" >> prod.in;

# if [ -f "prod.in" ];then
        # echo "prod.in - Done"
# else
        # echo "prod.in - Not Done"
# fi


# Water Minimization, Heating and Density Equilibration

echo "***************************************************";
echo "Selected CUDA device for the current MD = $2";
echo "***************************************************";

export CUDA_VISIBLE_DEVICES=$2

# pmemd.cuda -O -i watermin.in -o watermin.out -p com-sol1.prmtop -c com-sol1.inpcrd -r watermin.rst -ref com-sol1.inpcrd
# pmemd.cuda -O -i min.in -o min.out -p com-sol1.prmtop -c watermin.rst -r min.rst -x min.mdcrd -ref watermin.rst
# pmemd.cuda -O -i heat.in -o heat.out -p com-sol1.prmtop -c min.rst -r heat.rst -x heat.mdcrd -ref min.rst
# pmemd.cuda -O -i heat1.in -o heat1.out -p com-sol1.prmtop -c heat.rst -r heat1.rst -x heat1.mdcrd -ref heat.rst
# pmemd.cuda -O -i densi.in -o densi.out -p com-sol1.prmtop -c heat1.rst -r density.rst -x densi.nc -ref heat1.rst

# if [ -f density.rst ];then
	# pmemd.cuda -O -i equil.in -o equil.out -p com-sol1.prmtop -c density.rst -r equil.rst -x equil.nc -ref density.rst
	# pmemd.cuda -O -i equil1.in -o equil1.out -p com-sol1.prmtop -c equil.rst -r equil1.rst -x equil1.nc -ref equil.rst
	# pmemd.cuda -O -i prod.in -o prod1.out -p com-sol1.prmtop -c equil1.rst -r prod1.rst -x prod1.nc -ref equil1.rst
# else
	# sander -O -i densi.in -o densi.out -p com-sol1.prmtop -c heat1.rst -r density.rst -x densi.nc -ref heat1.rst
	# pmemd.cuda -O -i equil.in -o equil.out -p com-sol1.prmtop -c density.rst -r equil.rst -x equil.nc -ref density.rst
	# pmemd.cuda -O -i equil1.in -o equil1.out -p com-sol1.prmtop -c equil.rst -r equil1.rst -x equil1.nc -ref equil.rst
	# pmemd.cuda -O -i prod.in -o prod1.out -p com-sol1.prmtop -c equil1.rst -r prod1.rst -x prod1.nc -ref equil1.rst
# fi

pmemd.cuda -O -i equil.in -o equil.out -p com-sol1.prmtop -c density.rst -r equil.rst -x equil.nc -ref density.rst
pmemd.cuda -O -i equil1.in -o equil1.out -p com-sol1.prmtop -c equil.rst -r equil1.rst -x equil1.nc -ref equil.rst
pmemd.cuda -O -i prod.in -o prod1.out -p com-sol1.prmtop -c equil1.rst -r prod1.rst -x prod1.nc -ref equil1.rst


# Frame calculation
a=500; # Frames per ns
b=500000; # Time Steps per ns
tp=$((ts / b));
z=$((tp / 5));


if [ ! -e prod1.nc ];then
    echo "";
    echo "-----------------------------------------------------------";
    echo "| Further Analysis can't be done as prod1.nc is not found |";
    echo "-----------------------------------------------------------";
    echo "";
    exit
fi

# Current directory
dir=$(pwd | grep -o '[^/]*$')

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
	echo "Name of the Trajectory: prod1.nc";
	echo "Time period (ns): $ns";
	echo "Frame No.: $frame";
	echo "***********************************************************";


	rm extframe_$ns.in;

	echo "trajin prod1.nc $frame $frame 1" >> extframe_$ns.in;
	echo "reference com-sol1.inpcrd" >> extframe_$ns.in;
	echo "strip :Na+" >> extframe_$ns.in;
	echo "strip :Cl-" >> extframe_$ns.in;
	echo "strip :WAT" >> extframe_$ns.in;
	echo "trajout $dir"_ns_"$ns.pdb" >> extframe_$ns.in;

	cpptraj -p com-sol1.prmtop -i extframe_$ns.in > extframe_$ns.out;

	echo "***********************************************************";
	echo "Extraction of frame at $ns ns - Done";
	echo "***********************************************************";
	z=$((z - 1));
done

mv $dir*.pdb frames_$1/


# Residue No. Assignment and timestep calculation
lignum=$(awk '/UNK/ { print $5;exit; }' com.pdb);
recend=$((lignum - 1))


ts=$(awk '/nstlim/ { print $1 }' prod.in | awk -F '[=,]' '{ print $2 }');

# Frame calculation
a=500; # Frames per ns
b=500000; # Time Steps per ns
tp=$((ts / b));
frame=$((tp * a));

echo "Protein Start: 1";
echo "Protein End: $recend";
echo "Ligand No.: $lignum";
echo "Name of the Trajectory: prod1.nc";
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

if [ -f graphs_$1/ ];then
	rm -r graphs_$1/;
fi

mkdir graphs_$1

# Basic Trajectory Analysis
echo "trajin prod1.nc 0 $frame 1" >> analysis.in;
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

echo "Conversion of .agr files to .png - Done"; 

mv protein-rmsd.agr c-alpha-rmsd.agr lig-rmsd.agr rmsf.agr RoG.agr conv_agr_png.sh graphs_$1/
mv protein-rmsd.png c-alpha-rmsd.png lig-rmsd.png rmsf.png RoG.png graphs_$1/

# Extraction of Trajectory with 20 WAT around ligand

if [ -f exttraj_$1/ ];then
	rm -r exttraj_$1/;
fi

mkdir exttraj_$1

echo "trajin prod1.nc 0 $frame 10" >> exttraj_wat.in;
echo "reference equil1.rst" >> exttraj_wat.in;
echo "center :1-$lignum" >> exttraj_wat.in;
echo "autoimage" >> exttraj_wat.in;
echo "closest 20 :$lignum first" >> exttraj_wat.in;
echo "strip :Na+" >> exttraj_wat.in;
echo "strip :Cl-" >> exttraj_wat.in;
echo "trajout traj_20WAT.pdb pdb append" >> exttraj_wat.in;

cpptraj -p com-sol1.prmtop -i exttraj_wat.in > exttraj_wat.out;

echo "Extraction of Trajectory with 20 WAT - Done";
echo "**************************************************";

mv traj_20WAT.pdb exttraj_$1/

if [ -f hbond_$1/ ];then
	rm -r hbond_$1/;
fi


mkdir hbond_$1

echo "trajin prod1.nc 2000 $frame 1" >> hbond.in
echo "hbond contacts :1-$lignum avgout avg_$dir.dat series uuseries hbond.gnu nointramol" >> hbond.in
echo "go" >> hbond.in
echo "lifetime contacts[solutehb] out contacts-lifetime.dat" >> hbond.in
echo "go" >> hbond.in

cpptraj -p com-sol1.prmtop -i hbond.in > hbond.out

echo "Hbond calculation - Done";
echo "**************************************************";

mv avg.dat contacts-lifetime.dat crv.contacts-lifetime.dat hbond.gnu hbond_$1/


# Traj Start and End for MMPBSA

pbsaend=$((y * 500))
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
echo "Name of the Trajectory: prod1.nc";
echo "Trajectory Start: $pbsastart";
echo "Trajectory End: $pbsaend";
echo "Interval: $int";
echo "----------------------------------------------------";

if [ -f mmpbsa_py_$1/ ];then
	rm -r mmpbsa_py_$1/;
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

echo "#!/bin/sh" >> run_mmpbsa_decomp_gb.sh;
echo "\$AMBERHOME/bin/MMPBSA.py -O -i mmpbsa_per_res_decomp_gb.in -o FINAL_RESULTS_MMPBSA.dat -do FINAL_DECOMP_MMPBSA.dat -sp ../com-sol1.prmtop -cp ../com.prmtop -rp ../rec.prmtop -lp ../UNK_$ligand/UNK.prmtop -y ../prod1.nc" >> run_mmpbsa_decomp_gb.sh;

echo "----------------------------------------------------";
echo "mmpbsa_per_res_decomp_gb.in - Created";
echo "run_mmpbsa_decomp_gb.sh - Created";
echo "These input files perform free energy calculation on $s snapshots";
echo "****************************************************";


mkdir mmpbsa_py_$1
mv mmpbsa_per_res_decomp_gb.in run_mmpbsa_decomp_gb.sh mmpbsa_py_$1/

cd mmpbsa_py_$1

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
be=$(grep -i 'DELTA TOTAL' ./mmpbsa_py_$1/FINAL_RESULTS_MMPBSA.dat | awk '{ print $3 "," $5 }')
echo $dir $be | awk '{ print $1 "," $2 "," $3 }' > BE_$dir.csv

# Extract delta values of  per residue decomposition energies greater than -1.0 kcal/mol 
echo "PerResidueEnergyDecomposition Residue dGbind Std.Err." | awk '{ print $1 "\n" $2 "," $3 "," $4 }' > H_PRED_$dir.csv
awk '/^Total Energy Decomposition:/,/^Sidechain Energy Decomposition:/' ./mmpbsa_py_$1/FINAL_DECOMP_MMPBSA.dat > temp.csv
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

if [ -f dg_$1 ];then
	rm -r dg_$1;
	mkdir dg_$1;
else
	mkdir dg_$1;
fi



mv pred_$dir.png BE_$dir.csv PRED_$dir.csv BE+PRED_$dir.csv dg_$1/