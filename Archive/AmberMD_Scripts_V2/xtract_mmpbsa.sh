#!/bin/bash
dir=$(pwd | grep -o '[^/]*$')

# Extract Binding energy value from FINAL result
echo "BindingEnergy Ligand dGbind Std.Err." | awk '{ print $1 "\n" $2 "\t" $3 "\t" $4 }' > head1.txt
be=$(grep -i 'DELTA TOTAL' ./mmpbsa_py/FINAL_RESULTS_MMPBSA.dat | awk '{ print  "\t" $3 "\t" $5 }')
echo $dir $be | awk '{ print $1 "\t" $2 "\t" $3 }' > BE_$dir.txt

# Extract delta values of  per residue decomposition energies greater than -1.0 kcal/mol 
echo "PerResidueEnergyDecomposition Residue dGbind Std.Err." | awk '{ print $1 "\n" $2 "\t" $3 "\t" $4 }' > head2.txt
awk '/^Total Energy Decomposition:/,/^Sidechain Energy Decomposition:/' ./mmpbsa_py/FINAL_DECOMP_MMPBSA.dat > temp.txt
sed -i '/Total Energy Decomposition/d' temp.txt
sed -i '/Sidechain Energy Decomposition/d' temp.txt
awk -F '[,]' '{ print $1 "\t" $18 "\t" $20 }' temp.txt > temp2.txt
sed -i '1,2d' temp2.txt
sed -i '/UNK/d' temp2.txt
awk '$3 <= -1.0' temp2.txt | sort -k 3n > PRED_$dir.txt
d=$(echo "----------------------------------------------------------")
echo "$dir $d" | awk '{ print $1 "\n" $2 }' > BE+PRED_$dir.txt
cat head1.txt BE_$dir.txt head2.txt PRED_$dir.txt >> BE+PRED_$dir.txt
rm head1.txt head2.txt temp.txt temp2.txt