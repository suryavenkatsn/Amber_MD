#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will prepare both protein and ligand files for MD"
    echo ""
    echo "Usage: $0 -l <ligand1 name>"
    echo ""
    echo "Example: $0 -l UNK.mol2 "
    echo ""
    exit
fi

while getopts l: flag
do
	case "${flag}" in
		l) lig=${OPTARG};;
	esac
done

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
ligand=$(echo "$lig" | awk -F '[.]' '{ print $1 }')
# Extract charge from the input ligand file
grep -A 1 'i_epik_Tot_Q' $ligand.sdf >> TotQ_$ligand.txt
charge=$(tail -1 TotQ_$ligand.txt)

echo ""
echo "--------------------------------------------------";
echo "Name of the Ligand: $lig ";
echo "Charge of the Ligand: $charge ";
echo "--------------------------------------------------";


mkdir UNK_$ligand
cd UNK_$ligand

antechamber -i ../$ligand.mol2 -fi mol2 -o $ligand-ac.mol2 -fo mol2 -nc $charge -c bcc -dr no;

$AMBERHOME/bin/./parmchk2 -i $ligand-ac.mol2 -f mol2 -o frcmod.UNK;


printf "source $AMBERHOME/dat/leap/cmd/oldff/leaprc.ff99SB
source $AMBERHOME/dat/leap/cmd/leaprc.gaff
$ligand = loadmol2 $ligand-ac.mol2
check $ligand
loadamberparams frcmod.UNK
saveoff $ligand UNK.lib
saveamberparm $ligand UNK.prmtop UNK.inpcrd
savepdb $ligand UNKlig.pdb
quit" >> ligprp_$ligand.in;

tleap -f ligprp_$ligand.in > ligprp_$ligand.out;


tail -1 ligprp_$ligand.out

echo "--------------------------------------------------";
echo "Parameterization of $ligand - Done";
echo "**************************************************";

cd ../
