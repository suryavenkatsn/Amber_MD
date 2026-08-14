#!/bin/bash

if [ ! -n "$1" ];then
    echo ""
    echo "This script will extract required data from mmpbsa results"
    echo
    echo "Usage: $0 <ns>"
    echo ""
    echo "Example: $0 20"
    echo "This will extract required data from mmpbsa results of 20 ns  MD simulation"
    echo
    exit
fi

dir=$(pwd | grep -o '[^/]*$')


rm -f BE_$dir.csv;
rm -f PRED_$dir.csv;
rm -f BE+PRED_$dir.csv;

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
	mv pred_$dir.png BE_$dir.csv PRED_$dir.csv BE+PRED_$dir.csv dg_$1/
else
	mkdir dg_$1;
	mv pred_$dir.png BE_$dir.csv PRED_$dir.csv BE+PRED_$dir.csv dg_$1/
fi


