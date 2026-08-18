#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will model the input protein and ligand in a solvated sytem for MD"
    echo ""
    echo "Usage: $0 <protein name> <ligand name> <ligand2 name>"
    echo ""
    echo "Example: $0 3tyv.pdb UNK.mol2 UNK2.mol2"
    echo ""
    exit
fi

# Python Check

ver=$(python3 -V 2>&1 | sed 's/.* \([0-9]\).\([0-9]\).*/\1\2/')
if [ $ver -lt 30 ];then
	echo "Upgrade the Python to version greater than 3.0"
	echo ""
	exit
fi

ligand=$(echo "$2" | awk -F '[.]' '{ print $1 }')
ligand2=$(echo "$3" | awk -F '[.]' '{ print $1 }')

echo "";
echo "--------------------------------------------------";
echo "Name of the Protein: $1 ";
echo "Name of the Ligand: $ligand.mol2 ";
echo "Name of the Ligand2: $ligand2.mol2 ";
echo "--------------------------------------------------";


# Complex Preparation
rm -f comprp.in comprp.out complex.pdb

for i in UNK_*;
do echo $i;
cat ./$i/UNKlig.pdb | sed '/END/d' >> UNKlig_comp.pdb;
done;

cat rec.pdb | sed '/END/d' > rec1.pdb;
cat rec1.pdb UNKlig_comp.pdb >> complex.pdb;
echo "END" >> complex.pdb;
rm rec1.pdb
rm UNKlig_comp.pdb

printf "source $AMBERHOME/dat/leap/cmd/oldff/leaprc.ff99SB
source $AMBERHOME/dat/leap/cmd/leaprc.zinc
source $AMBERHOME/dat/leap/cmd/leaprc.gaff
loadamberparams ./UNK_$ligand/frcmod.UNK
loadoff ./UNK_$ligand/UNK.lib
loadamberparams ./UNK_$ligand2/frcmod.UNK
loadoff ./UNK_$ligand2/UNK.lib
complex = loadpdb complex.pdb
saveamberparm  complex com.prmtop com.inpcrd
savepdb complex com.pdb
quit" >> comprp.in;

tleap -f comprp.in > comprp.out;

echo "**************************************************";
tail -1 comprp.out

echo "--------------------------------------------------";
echo "Complex Parameterization - Done";
echo "**************************************************";

