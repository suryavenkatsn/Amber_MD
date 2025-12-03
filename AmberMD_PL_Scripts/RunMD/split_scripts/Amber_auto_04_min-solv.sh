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


# Running Ligand and Complex Minimization

if [ ! -f drug.in ] && [ ! -f complexmin.in ];then
	echo "***One or more input files are not available. Please ensure all the input files are in place before running minimization***"
	exit
fi

sander -O -i drug.in -o drug.out -p com.prmtop -c com.inpcrd -r drug.rst -x drug.mdcrd -ref com.inpcrd
sander -O -i complexmin.in -o complexmin.out -p com.prmtop -c drug.rst -r complexmin.rst -x complexmin.mdcrd -ref drug.rst

# Estimation of charge and volume of system


if [ -f solv_c.in ];then
	rm solv_c.in;
fi 

if [ -f solv_charge.out ];then
	rm solv_charge.out;
fi 

if [ -f complexmin.pdb ];then
	rm complexmin.pdb;
fi

$AMBERHOME/bin/./ambpdb -p com.prmtop -c complexmin.rst > complexmin.pdb

printf "source $AMBERHOME/dat/leap/cmd/oldff/leaprc.ff99SB
source $AMBERHOME/dat/leap/cmd/leaprc.zinc
source $AMBERHOME/dat/leap/cmd/leaprc.gaff
loadamberparams ./UNK_$ligand/frcmod.UNK
loadoff ./UNK_$ligand/UNK.lib
loadamberparams ./UNK_$ligand2/frcmod.UNK
loadoff ./UNK_$ligand2/UNK.lib
complex = loadpdb complexmin.pdb
solvatebox complex TIP3PBOX 10.0
charge complex
quit" >> solv_c.in

tleap -f solv_c.in > solv_charge.out

charge=$(awk '/Total unperturbed charge/ { print $4;exit; }' leap.log);
vol=$(awk '/Volume/ { print $2;exit; }' leap.log);



# Calculation using python
python3 ions_nacl.py -i $charge >> ions.txt
python3 sc_calcs.py -v $vol >> sc.txt

ion=$(tail -1 ions.txt)
nacl=$(tail -1 sc.txt)

# Solvation of the System
if [ -f solv.in ];then
        rm solv.in;
fi

if [ -f solv.out ];then
        rm solv.out;
fi

if [ -f complexmin.pdb ];then
        rm complexmin.pdb;
fi

$AMBERHOME/bin/./ambpdb -p com.prmtop -c complexmin.rst > complexmin.pdb

printf "source $AMBERHOME/dat/leap/cmd/oldff/leaprc.ff99SB
source $AMBERHOME/dat/leap/cmd/leaprc.zinc
source $AMBERHOME/dat/leap/cmd/leaprc.gaff
loadamberparams ./UNK_$ligand/frcmod.UNK
loadoff ./UNK_$ligand/UNK.lib
loadamberparams ./UNK_$ligand2/frcmod.UNK
loadoff ./UNK_$ligand2/UNK.lib
complex = loadpdb complexmin.pdb
solvatebox complex TIP3PBOX 10.0
charge complex
addIons complex $ion 0
addIonsRand complex Na+ $nacl Cl- $nacl
saveamberparm complex com-sol1.prmtop com-sol1.inpcrd
savepdb complex com-sol1.pdb
quit" >> solv.in

tleap -f solv.in > solv.out

echo "**************************************************";
tail -1 solv.out


echo "--------------------------------------------------";
echo "Complex Solvation - Done";
echo "Check the solvated system and run MD simulation";
echo "**************************************************";






