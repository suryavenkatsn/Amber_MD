#!/bin/bash


# Remove exisiting files to avoid duplication
rm comprp.in;
rm complex.pdb;


cat rec.pdb | sed '/END/d' > complex.pdb;
cat complex.pdb UNKlig.pdb >> complex.pdb;

echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> comprp.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.zinc" >> comprp.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> comprp.in;
echo "loadamberparams frcmod.UNK" >> comprp.in;
echo "loadoff UNK.lib" >> comprp.in;
echo "complex = loadpdb complex.pdb" >> comprp.in;
echo "saveamberparm  complex com.prmtop com.inpcrd" >> comprp.in;
echo "savepdb complex com.pdb" >> comprp.in;
echo "quit" >> comprp.in;

cat comprp.in;

tleap -f comprp.in > comprp.out;

echo "";

tail -1 comprp.out

echo "";
echo "**************************************************";
echo "Complex Parameterization is done successfully!";
echo "**************************************************";
