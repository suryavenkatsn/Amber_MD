#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will parameterize and prepare protein files for MD"
    echo ""
    echo "Usage: $0 <protein name>"
    echo ""
    echo "Example: $0 3tyv.pdb"
    echo "This will parameterize the protein"
    echo ""
    exit
fi

echo "**************************************************";
echo Name of the Protein: $1;
echo "**************************************************";

rm prtprp.in;


echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> prtprp.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.zinc" >> prtprp.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> prtprp.in;
echo "pro = loadpdb $1" >> prtprp.in;
echo "saveamberparm pro rec.prmtop rec.inpcrd" >> prtprp.in;
echo "savepdb  pro rec.pdb" >> prtprp.in;
echo "quit" >> prtprp.in;

cat prtprp.in;

tleap -f prtprp.in > prtprp.out;

echo "";

tail -1 prtprp.out

echo "";

echo "**************************************************";
echo "Protein Parameterization is done successfully!";
echo "**************************************************";
