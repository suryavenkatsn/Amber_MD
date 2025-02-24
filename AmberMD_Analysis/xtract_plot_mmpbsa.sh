#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "Usage: $0 -n 20"
    echo ""
    echo "Example: $0 -n 20"
    exit
fi

while getopts n: flag
do
	case "${flag}" in
		n) ns=${OPTARG};;
	esac
done


dir=$(pwd | grep -o '[^/]*$')

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
be=$(grep -i 'DELTA TOTAL' ./mmpbsa_py_$ns/FINAL_RESULTS_MMPBSA.dat | awk '{ print $3 "," $5 }')
echo $dir $be | awk '{ print $1 "," $2 "," $3 }' > BE_$dir.csv

# Extract delta values of  per residue decomposition energies greater than -1.0 kcal/mol 
echo "PerResidueEnergyDecomposition Residue dGbind Std.Err." | awk '{ print $1 "\n" $2 "," $3 "," $4 }' > H_PRED_$dir.csv
awk '/^Total Energy Decomposition:/,/^Sidechain Energy Decomposition:/' ./mmpbsa_py_$ns/FINAL_DECOMP_MMPBSA.dat > temp.csv
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


if [ -f dg_$ns ];then
	mv pred_$dir.png BE_$dir.csv PRED_$dir.csv BE+PRED_$dir.csv dg_$ns/
else
	mkdir dg_$ns;
	mv pred_$dir.png BE_$dir.csv PRED_$dir.csv BE+PRED_$dir.csv dg_$ns/
fi



