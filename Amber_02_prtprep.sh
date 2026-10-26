#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "Usage: $0 <protein name>"
    echo "Example: $0 3tyv.pdb"
    echo ""
    exit
fi

# Protein Preparation
protein=$(echo "$1" | awk -F '[.]' '{ print $1 }')

printf "source $AMBERHOME/dat/leap/cmd/leaprc.protein.ff19SB
source $AMBERHOME/dat/leap/cmd/leaprc.gaff2
pro = loadpdb $1
saveamberparm pro rec.prmtop rec.inpcrd
savepdb  pro rec.pdb
quit" > prtprp_${protein}.in;

tleap -f prtprp_${protein}.in > prtprp_${protein}.out;

echo "**************************************************";
tail -1 prtprp_${protein}.out
echo "--------------------------------------------------";
echo "Parameterization of ${protein} is completed.";
echo "--------------------------------------------------";