#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will model the input protein and ligand in a solvated sytem for MD"
    echo ""
    echo "Usage: $0 <protein name> <ligand name>"
    echo ""
    echo "Example: $0 3tyv.pdb UNK.mol2"
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

echo "";
echo "--------------------------------------------------";
echo "Name of the Protein: $1 ";
echo "Name of the Ligand: $ligand.mol2 ";
echo "--------------------------------------------------";

# Protein Preparation

if [ -f prtprp.in ];then
        rm prtprp.in;
fi

if [ -f prtprp.out ];then
        rm prtprp.out;
fi

if [ -f prtprp_ss.in ];then
	rm prtprp_ss.in;
fi

if [ -f prtprp_ss.out ];then
	rm prtprp_ss.out;
fi

if [ -f ssbond.in ];then
	echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> prtprp_ss.in;
    echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.zinc" >> prtprp_ss.in;
    echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> prtprp_ss.in;
    echo "pro = loadpdb $1" >> prtprp_ss.in;
    echo "saveamberparm pro rec.prmtop rec.inpcrd" >> prtprp_ss.in;
    echo "savepdb  pro rec.pdb" >> prtprp_ss.in;
    echo "quit" >> prtprp_ss.in;

    tleap -f prtprp_ss.in > prtprp_ss.out;

	echo "**************************************************";
	tail -1 prtprp_ss.out

else
	echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> prtprp.in;
	echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.zinc" >> prtprp.in;
	echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> prtprp.in;
	echo "pro = loadpdb $1" >> prtprp.in;
	echo "saveamberparm pro rec.prmtop rec.inpcrd" >> prtprp.in;
	echo "savepdb  pro rec.pdb" >> prtprp.in;
	echo "quit" >> prtprp.in;

	tleap -f prtprp.in > prtprp.out;
	
	echo "**************************************************";
	tail -1 prtprp.out
fi

echo "--------------------------------------------------";
echo "Protein Parameterization - Done!";
echo "**************************************************";