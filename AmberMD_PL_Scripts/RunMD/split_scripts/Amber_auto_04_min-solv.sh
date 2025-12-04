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

# Input files generation for ligand and complex minimization


recstart=1
recend=$(tail -3 rec.pdb | awk '{print $5}')


echo "----------------------INPUTS----------------------";
echo "Protein Start: $recstart ";
echo "Protein End: $recend ";
echo "--------------------------------------------------";
echo "---------------INPUT FILES CREATED--------------- ";

if [ -f drug.in ];then
        rm drug.in;
fi

if [ -f complexmin.in ];then
        rm complexmin.in;
fi

# Input file for Ligand Minimization
printf "Minimize drug coords and xtal water
 &cntrl
  imin = 1,
  maxcyc = 1000,
  ncyc = 500,
  ntr = 1,
  ntb = 0,
  cut = 16.0,
/
Keep protein fixed
10.0
RES $recstart $recend
END
END" >> drug.in;

if [ -f "drug.in" ];then
        echo "drug.in - Done"
else
        echo "drug.in - Not Done"
fi


# Input file for Complex Minimization

printf "Minimize water positions (and all hydrogens)
 &cntrl
  imin = 1,
  maxcyc = 1000,
  ncyc = 500,
  ntr = 1,
  ntb = 0,cut=16.0,
/
END" >> complexmin.in;

if [ -f "complexmin.in" ];then
        echo "complexmin.in - Done"
else
        echo "complexmin.in - Not Done"
fi


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

rm -f solv_c.in solv_charge.out complexmin.pdb


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

rm -f solv.in solv.out complexmin.pdb

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






