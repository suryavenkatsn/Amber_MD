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

$AMBERHOME/bin/./parmchk2 -i $ligand-ac.mol2 -f mol2 -o frcmod.UNK;

rm ligprp.in;

echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> ligprp.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> ligprp.in;
echo "UNK = loadmol2 $ligand-ac.mol2" >> ligprp.in;
echo "check UNK" >> ligprp.in;
echo "loadamberparams frcmod.UNK" >> ligprp.in;
echo "saveoff UNK UNK.lib" >> ligprp.in;
echo "saveamberparm UNK UNK.prmtop UNK.inpcrd" >> ligprp.in;
echo "savepdb UNK UNKlig.pdb" >> ligprp.in;
echo "quit" >> ligprp.in;

cat ligprp.in;

tleap -f ligprp.in > ligprp.out;

echo "";

tail -1 ligprp.out

echo "";

echo "**************************************************";
echo "Ligand Parameterization is done successfully!";
echo "**************************************************";


