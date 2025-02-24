#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will prepare both protein files for MD"
    echo ""
    echo "Usage: $0 -p <Protein name>"
    echo ""
    echo "Example: $0 -p 3tyv.pdb"
    echo ""
    exit
fi

while getopts p: flag
do
	case "${flag}" in
		p) prt=${OPTARG};;
	esac
done


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
    echo "pro = loadpdb $prt" >> prtprp_ss.in;
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
	echo "pro = loadpdb $prt" >> prtprp.in;
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
