#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will parameterize and prepare protein and complex files for Mutants"
    echo ""
    echo "Usage: $0 <protein name> <mutant>"
    echo ""
    echo "Example: $0 3tyv D218A"
    echo "This will parameterize the mutant protein and complex"
    echo ""
    exit
fi

echo "**************************************************";
echo Name of the Protein: $1_$2;
echo "**************************************************";

rm prtprp_$2.in;


echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> prtprp_$2.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.zinc" >> prtprp_$2.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> prtprp_$2.in;
echo "pro = loadpdb $1_$2.pdb" >> prtprp_$2.in;
echo "saveamberparm pro rec_$2.prmtop rec_$2.inpcrd" >> prtprp_$2.in;
echo "savepdb  pro rec_$2.pdb" >> prtprp_$2.in;
echo "quit" >> prtprp_$2.in;

cat prtprp_$2.in;

tleap -f prtprp_$2.in > prtprp_$2.out;

echo "";

tail -1 prtprp_$2.out

echo "";

echo "**************************************************";
echo "Mutant Protein Parameterization is done successfully!";
echo "**************************************************";
