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
if [ -f comprp.in ];then
        rm comprp.in;
fi

if [ -f comprp.out ];then
        rm comprp.out;
fi

if [ -f complex.pdb ];then
        rm complex.pdb;
fi

for i in UNK_*;
do echo $i;
cat ./$i/UNKlig.pdb | sed '/END/d' >> UNKlig_comp.pdb;
done;

cat rec.pdb | sed '/END/d' > rec1.pdb;
cat rec1.pdb UNKlig_comp.pdb >> complex.pdb;
rm rec1.pdb
rm UNKlig_comp.pdb

echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> comprp.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.zinc" >> comprp.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> comprp.in;
echo "loadamberparams ./UNK_$ligand/frcmod.UNK" >> comprp.in;
echo "loadoff ./UNK_$ligand/UNK.lib" >> comprp.in;
echo "loadamberparams ./UNK_$ligand2/frcmod.UNK" >> comprp.in;
echo "loadoff ./UNK_$ligand2/UNK.lib" >> comprp.in;
echo "complex = loadpdb complex.pdb" >> comprp.in;
echo "saveamberparm  complex com.prmtop com.inpcrd" >> comprp.in;
echo "savepdb complex com.pdb" >> comprp.in;
echo "quit" >> comprp.in;

tleap -f comprp.in > comprp.out;

echo "**************************************************";
tail -1 comprp.out

echo "--------------------------------------------------";
echo "Complex Parameterization - Done";
echo "**************************************************";


# Input files generation for ligand and complex minimization

lignum=$(awk '/UNK/ { print $5;exit; }' com.pdb);
recstart=1
recend=$((lignum - 1))


echo "----------------------INPUTS----------------------";
echo "Protein Start: $recstart ";
echo "Protein End: $recend ";
echo "Ligand No.: $lignum ";
echo "--------------------------------------------------";
echo "---------------INPUT FILES CREATED--------------- ";

if [ -f drug.in ];then
        rm drug.in;
fi

if [ -f complexmin.in ];then
        rm complexmin.in;
fi

# Input file for Ligand Minimization
echo "Minimize drug coords (drug is resid $ligstart) and xtal water" >> drug.in;
echo " &cntrl" >> drug.in;
echo "  imin = 1," >> drug.in;
echo "  maxcyc = 1000," >> drug.in;
echo "  ncyc = 500," >> drug.in;
echo "  ntr = 1," >> drug.in;
echo "  ntb = 0," >> drug.in;
echo "  cut = 16.0," >> drug.in;
echo "/" >> drug.in;
echo "Keep protein fixed" >> drug.in;
echo "10.0" >> drug.in
echo "RES $recstart $recend" >> drug.in;
echo "END" >> drug.in;
echo "END" >> drug.in;

if [ -f "drug.in" ];then
        echo "drug.in - Done"
else
        echo "drug.in - Not Done"
fi


# Input file for Complex Minimization

echo "Minimize water positions (and all hydrogens)" >> complexmin.in;
echo " &cntrl" >> complexmin.in;
echo "  imin = 1," >> complexmin.in;
echo "  maxcyc = 1000," >> complexmin.in;
echo "  ncyc = 500," >> complexmin.in
echo "  ntr = 1," >> complexmin.in
echo "  ntb = 0,cut=16.0," >> complexmin.in
echo "/" >> complexmin.in;
echo "END" >> complexmin.in;

if [ -f "complexmin.in" ];then
        echo "complexmin.in - Done"
else
        echo "complexmin.in - Not Done"
fi
