#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "Usage: $0 <ligand1 name> <charge>"
    echo "Example: $0 UNK.mol2 1"
	echo ""
    exit
fi

# Extract Ligand name by stripping its file extension
ligand=$(echo "$1" | awk -F '[.]' '{ print $1 }')
charge=$2

mkdir UNK_${ligand}
cd UNK_${ligand}

antechamber -i ../${ligand}.mol2 -fi mol2 -o ${ligand}-ac.mol2 -fo mol2 -nc $charge -c bcc -dr no;

$AMBERHOME/bin/./parmchk2 -i ${ligand}-ac.mol2 -f mol2 -o frcmod.UNK;

printf "source $AMBERHOME/dat/leap/cmd/leaprc.protein.ff19SB
source $AMBERHOME/dat/leap/cmd/leaprc.gaff2
UNK = loadmol2 ${ligand}-ac.mol2
check UNK
loadamberparams frcmod.UNK
saveoff UNK UNK.lib
saveamberparm UNK UNK.prmtop UNK.inpcrd
savepdb UNK UNKlig.pdb
quit
" > ligprp_${ligand}.in;

tleap -f ligprp_${ligand}.in > ligprp_${ligand}.out;

echo "**************************************************";
tail -1 ligprp_${ligand}.out
echo "--------------------------------------------------";
echo "Parameterization of ${ligand} is completed.";
echo "--------------------------------------------------";

cd ../