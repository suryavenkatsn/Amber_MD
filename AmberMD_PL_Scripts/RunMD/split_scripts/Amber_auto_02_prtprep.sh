#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will model the input protein and ligand in a solvated sytem for MD"
    echo ""
    echo "Usage: $0 <protein name> <ligand name>"
    echo ""
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

ligand=$(echo "$2" | awk -F '[.]' '{ print $1 }')

echo "";
echo "--------------------------------------------------";
echo "Name of the Protein: $1 ";
echo "Name of the Ligand: $ligand.mol2 ";
echo "--------------------------------------------------";

# Protein Preparation

rm -f prtprp.in prtprp.out

printf " source $AMBERHOME/dat/leap/cmd/oldff/leaprc.ff99SB
source $AMBERHOME/dat/leap/cmd/leaprc.zinc
source $AMBERHOME/dat/leap/cmd/leaprc.gaff
pro = loadpdb $1
saveamberparm pro rec.prmtop rec.inpcrd
savepdb  pro rec.pdb
quit" >> prtprp.in;

tleap -f prtprp.in > prtprp.out;

echo "**************************************************";
tail -1 prtprp.out

echo "--------------------------------------------------";
echo "Protein Parameterization - Done!";
echo "**************************************************";