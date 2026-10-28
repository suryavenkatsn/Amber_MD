#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "Usage: $0 <protein name> <ligand name>"
    echo "Example: $0 3tyv.pdb UNK.mol2"
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

protein=$(echo "$1" | awk -F '[.]' '{ print $1 }')
ligand=$(echo "$2" | awk -F '[.]' '{ print $1 }')

# Complex Preparation
rm -f complex.pdb
cat rec.pdb | sed '/END/d' > rec1.pdb;
cat ./UNK_${ligand}/UNKlig.pdb | sed '/END/d' >> lig1.pdb;
cat rec1.pdb lig1.pdb >> complex.pdb;
echo "END" >> complex.pdb;
rm rec1.pdb lig1.pdb

printf "source $AMBERHOME/dat/leap/cmd/leaprc.protein.ff19SB
source $AMBERHOME/dat/leap/cmd/leaprc.gaff2
loadamberparams ./UNK_${ligand}/frcmod.UNK
loadoff ./UNK_${ligand}/UNK.lib
complex = loadpdb complex.pdb
saveamberparm  complex com.prmtop com.inpcrd
savepdb complex com.pdb
quit" > comprp.in;

tleap -f comprp.in > comprp.out;

echo "**************************************************";
tail -1 comprp.out
echo "--------------------------------------------------";
echo "Parameterization of complex is completed.";
echo "--------------------------------------------------";