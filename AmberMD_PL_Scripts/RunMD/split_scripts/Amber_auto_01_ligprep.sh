#!/bin/bash
if [ ! -n "$1" ];then
    printf "This script will parameterize and prepare ligand files for MD
    
    Usage: $0 <ligand1 name>
    
    Example: $0 UNK.mol2
    This will parameterize the ligand 'UNK.mol2'
    ";
    exit
fi

if [ -f TotQ_*.txt ];then
	rm TotQ_*.txt;
fi 

if [ -f ligprp_*.in ];then
	rm ligprp_*.in;
fi 

if [ -f ligprp_*.out ];then
	rm ligprp_*.out;
fi 

# splits ligand input name and its format extension
ligand=$(echo "$1" | awk -F '[.]' '{ print $1 }')
# Extract charge from the input ligand file
grep -A 1 'i_epik_Tot_Q' $ligand.sdf >> TotQ_$ligand.txt
charge=$(tail -1 TotQ_$ligand.txt)

printf "
-------------------------------------------------
Name of the Ligand: $1;
Charge of the Ligand: $charge;
-------------------------------------------------
";

mkdir UNK_$ligand
cd UNK_$ligand

antechamber -i ../$ligand.mol2 -fi mol2 -o $ligand-ac.mol2 -fo mol2 -nc $charge -c bcc -dr no;

$AMBERHOME/bin/./parmchk2 -i $ligand-ac.mol2 -f mol2 -o frcmod.UNK;

rm -f ligprp_$ligand.in ligprp_$ligand.out

printf "source $AMBERHOME/dat/leap/cmd/oldff/leaprc.ff99SB
source $AMBERHOME/dat/leap/cmd/leaprc.gaff
UNK = loadmol2 $ligand-ac.mol2
check UNK
loadamberparams frcmod.UNK
saveoff UNK UNK.lib
saveamberparm UNK UNK.prmtop UNK.inpcrd
savepdb UNK UNKlig.pdb
quit
" >> ligprp_$ligand.in;

tleap -f ligprp_$ligand.in > ligprp_$ligand.out;

echo "";

tail -1 ligprp_$ligand.out

printf "---------------------------------------------------
Parameterization of $ligand - Done
**************************************************";

cd ../