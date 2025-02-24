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

# Remove exisiting files to avoid duplication
rm comprp_$2.in;
rm complex_$2.pdb;

cat rec_$2.pdb | sed '/END/d' > complex_$2.pdb;
cat complex_$2.pdb UNKlig.pdb >> complex_$2.pdb;


echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> comprp_$2.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.zinc" >> comprp_$2.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> comprp_$2.in;
echo "loadamberparams frcmod.UNK" >> comprp_$2.in;
echo "loadoff UNK.lib" >> comprp_$2.in;
echo "complex = loadpdb complex_$2.pdb" >> comprp_$2.in;
echo "saveamberparm complex com_$2.prmtop com_$2.inpcrd" >> comprp_$2.in;
echo "savepdb complex com_$2.pdb" >> comprp_$2.in;
echo "quit" >> comprp_$2.in;

cat comprp_$2.in;

tleap -f comprp_$2.in > comprp_$2.out;

echo "";

tail -1 comprp_$2.out

echo "";


echo "**************************************************";
echo "Mutant complex Parameterization is done successfully!";
echo "**************************************************";

