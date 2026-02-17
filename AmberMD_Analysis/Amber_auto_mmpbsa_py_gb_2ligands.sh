#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will create input and sh file for mmpbsa calculation from the input trajectory"
    echo
    echo "Usage: $0 <ns> <trajectory name>"
    echo ""
    echo "Example: $0 20 prod1.nc"
    echo "This will create input for mmpbsa calculation for ~ 50 snapshots from the trajectory"
    echo
    exit
fi


y=$1
pbsaend=$((y * 500))
pbsastart=$((pbsaend * 80 / 100))
int=$(((pbsaend - pbsastart) / 50 ))

dir=$(pwd | grep -o '[^/]*$')

recstart=1
recend=$(tail -3 rec.pdb | awk '{print $5}')
compend=$(tail -3 com.pdb | awk '{print $5}')

rm -f ligname.txt

# for i in *.mol2; do echo $i; echo $i | awk -F '[.]' '{ print $1 }' >> ligname.txt ; done
for i in UNK_*; do echo $i >> ligname.txt; done
# wc -l lig.txt | awk '{print $1}' > ligcount.txt

ligname1=$(sed -n '1p' ligname.txt)
ligname2=$(sed -n '2p' ligname.txt)
ligand1=$(sed -n '1p' lig.txt)
ligand2=$(sed -n '2p' lig.txt)
lignum1=$(awk -v lig="$ligand1" '$0 ~ lig { print $5; exit }' com.pdb)
lignum2=$(awk -v lig="$ligand2" '$0 ~ lig { print $5; exit }' com.pdb)

# ligand=$(echo *.mol2 | awk -F '[.]' '{ print $1 }')
# lignum=$(awk '/UNK/ { print $5;exit; }' com.pdb);


echo "";
echo "****************************************************";
echo "Protein Start: $recstart";
echo "Protein End: $recend";
echo "$ligand1 Number: $lignum1";
echo "$ligand2 Number: $lignum2";
echo "Name of the Trajectory: $2";
echo "Trajectory Start: $pbsastart";
echo "Trajectory End: $pbsaend";
echo "Interval: $int";
echo "----------------------------------------------------";

if [ -f mmpbsa_py_$1 ];then
	rm -r mmpbsa_py_$1;
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
echo "  idecomp=1, print_res=\"5; $recstart-$recend; $lignum2\"" >> mmpbsa_per_res_decomp_gb.in;
echo "  dec_verbose=1," >> mmpbsa_per_res_decomp_gb.in;
echo "/" >> mmpbsa_per_res_decomp_gb.in;

i=$pbsastart;
j=$pbsaend;
k=$int;
r=$((j - i));
s=$((r / k));

# Script to run mmpbsa.py (Only GB decomposition)

echo "#!/bin/sh" >> run_mmpbsa_decomp_gb.sh;
echo "\$AMBERHOME/bin/MMPBSA.py -O -i mmpbsa_per_res_decomp_gb.in -o FINAL_RESULTS_MMPBSA.dat -do FINAL_DECOMP_MMPBSA.dat -sp ../com-sol1.prmtop -cp ../com.prmtop -rp ../rec.prmtop -lp ../$ligname2/UNK.prmtop -y ../$2" >> run_mmpbsa_decomp_gb.sh;

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

