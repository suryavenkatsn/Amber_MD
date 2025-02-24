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
    echo "Example: $0 -u UNK -c -1"
    echo "This will parameterize the ligand 'UNK' with charge -1"
    echo ""
    exit
fi

while getopts u:c: flag
do
	case "${flag}" in
		u) ligand=${OPTARG};;
		c) charge=${OPTARG};;
	esac
done

echo Name of the Ligand: $ligand.mol2;
echo Charge of the Ligand: $charge;

if [ ! -f $ligand.mol2 ];then
        echo ""
		echo "------Provide valid LIGAND NAME without extension------"
		echo ""
		exit
fi


antechamber -i $ligand.mol2 -fi mol2 -o $ligand-ac.mol2 -fo mol2 -nc $charge -c bcc -dr no;

$AMBERHOME/bin/./parmchk2 -i $ligand-ac.mol2 -f mol2 -o frcmod_1.UNK;
	
if [ -f ligprp_1.in ];then
	rm ligprp_1.in;
fi

echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> ligprp_1.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> ligprp_1.in;
echo "UNK = loadmol2 $ligand-ac.mol2" >> ligprp_1.in;
echo "check UNK" >> ligprp_1.in;
echo "loadamberparams frcmod_1.UNK" >> ligprp_1.in;
echo "saveoff UNK UNK_1.lib" >> ligprp_1.in;
echo "saveamberparm UNK UNK_1.prmtop UNK_1.inpcrd" >> ligprp_1.in;
echo "savepdb UNK UNKlig_1.pdb" >> ligprp_1.in;
echo "quit" >> ligprp_1.in;

cat ligprp_1.in;

tleap -f ligprp_1.in > ligprp_1.out;

echo "";

tail -1 ligprp_1.out

echo "";

echo "**************************************************";
echo "Ligand Parameterization is done successfully!";
echo "**************************************************";


