#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "Usage: $0 <protein name> <ligand name>"
    echo "Example: $0 3tyv.pdb UNK.mol2"
    echo ""
    exit
fi

# Python version check
ver=$(python3 -V 2>&1 | sed 's/.* \([0-9]\).\([0-9]\).*/\1\2/')
if [ $ver -lt 30 ];then
	echo "Upgrade the Python to version greater than 3.0"
	echo ""
	exit
fi

protein=$(echo "$1" | awk -F '[.]' '{ print $1 }')
ligand=$(echo "$2" | awk -F '[.]' '{ print $1 }')

# Input files generation for ligand and complex minimization
comstart=1
comend=$(tail -3 com.pdb | awk '{print $5}')

# Input file for Ligand Minimization
printf "Minimize ligand and crystallographic waters
&cntrl
  imin = 1,
  maxcyc = 1000,
  ncyc = 500,
  ntr = 1,
  restraint_wt = 10.0,
  restraintmask = ':$comstart-$comend & !:UNK',
  ntb = 0,
  cut = 16.0,
/
" > drug.in;

# Input file for Complex Minimization
printf "Minimize water positions (and all hydrogens)
 &cntrl
  imin = 1,
  maxcyc = 1000,
  ncyc = 500,
  ntr = 1,
  ntb = 0,cut=16.0,
/
END" > complexmin.in;

sander -O -i drug.in -o drug.out -p com.prmtop -c com.inpcrd -r drug.rst -x drug.mdcrd -ref com.inpcrd
sander -O -i complexmin.in -o complexmin.out -p com.prmtop -c drug.rst -r complexmin.rst -x complexmin.mdcrd -ref drug.rst

# Estimation of charge and volume of system
$AMBERHOME/bin/./ambpdb -p com.prmtop -c complexmin.rst > complexmin.pdb

printf "source $AMBERHOME/dat/leap/cmd/leaprc.protein.ff19SB
source $AMBERHOME/dat/leap/cmd/leaprc.gaff2
loadamberparams ./UNK_${ligand}/frcmod.UNK
loadoff ./UNK_${ligand}/UNK.lib
complex = loadpdb complexmin.pdb
solvatebox complex TIP3PBOX 10.0
charge complex
quit" > solv_c.in

tleap -f solv_c.in > solv_charge.out

vol=$(awk '/Volume/ { print $2;exit; }' leap.log);

# Calculation using python
python3 sc_calcs.py -v ${vol} > sc.txt

nacl=$(tail -1 sc.txt)

$AMBERHOME/bin/./ambpdb -p com.prmtop -c complexmin.rst > complexmin.pdb

printf "source $AMBERHOME/dat/leap/cmd/leaprc.protein.ff19SB
source $AMBERHOME/dat/leap/cmd/leaprc.gaff2
loadamberparams ./UNK_${ligand}/frcmod.UNK
loadoff ./UNK_${ligand}/UNK.lib
complex = loadpdb complexmin.pdb
solvatebox complex TIP3PBOX 10.0
charge complex
addIons complex Na+ 0
addIons complex Cl- 0
addIonsRand complex Na+ ${nacl} Cl- ${nacl}
saveamberparm complex com-sol1.prmtop com-sol1.inpcrd
savepdb complex com-sol1.pdb
quit" > solv.in

tleap -f solv.in > solv.out

echo "*******************************************************";
tail -1 solv.out
echo "-------------------------------------------------------";
echo "Solvation of Complex is completed";
echo "Check the solvated system and proceed for MD simulation";
echo "*******************************************************";






