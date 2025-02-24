#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will parameterize and prepare ligand files for MD"
    echo "Use the following flags to run the script"
	echo "-u = Name of the ligand"
	echo "-c = Charge of the ligand"
    echo ""
    echo "Usage: $0 -u <ligand name> -c <charge>"
    echo ""
    echo "Example: $0 -u UNK.mol2 -c -1"
    echo "This will parameterize the ligand 'UNK.mol2' with charge -1"
    echo ""
    exit
fi

while getopts u:c: flag
do
	case "${flag}" in
		u) lig=${OPTARG};;
		c) charge=${OPTARG};;
	esac
done

echo Name of the Ligand: $lig;
echo Charge of the Ligand: $charge;

ligand=$(echo "$lig" | awk -F '[.]' '{ print $1 }')


antechamber -i $ligand.mol2 -fi mol2 -o $ligand-ac.mol2 -fo mol2 -nc $charge -c bcc -dr no;

$AMBERHOME/bin/./parmchk2 -i $ligand-ac.mol2 -f mol2 -o frcmod_2.UNK;
	
if [ -f ligprp_2.in ];then
	rm ligprp_2.in;
fi

echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> ligprp_2.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> ligprp_2.in;
echo "UNK = loadmol2 $ligand-ac.mol2" >> ligprp_2.in;
echo "check UNK" >> ligprp_2.in;
echo "loadamberparams frcmod_2.UNK" >> ligprp_2.in;
echo "saveoff UNK UNK_2.lib" >> ligprp_2.in;
echo "saveamberparm UNK UNK_2.prmtop UNK_2.inpcrd" >> ligprp_2.in;
echo "savepdb UNK UNKlig_2.pdb" >> ligprp_2.in;
echo "quit" >> ligprp_2.in;

cat ligprp_2.in;

tleap -f ligprp_2.in > ligprp_2.out;

echo "";

tail -1 ligprp_2.out

echo "";

echo "**************************************************";
echo "Ligand Parameterization is done successfully!";
echo "**************************************************";


