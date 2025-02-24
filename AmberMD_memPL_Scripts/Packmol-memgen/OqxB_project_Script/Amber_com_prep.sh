#!/bin/bash

# Complex preparation

echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> comprp.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.zinc" >> comprp.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> comprp.in;
echo "loadamberparams ./UNK_A21/frcmod.UNK" >> comprp.in;
echo "loadoff ./UNK_A21/UNK.lib" >> comprp.in;
echo "loadamberparams ./UNK_A22/frcmod.UNK" >> comprp.in;
echo "loadoff ./UNK_A22/UNK.lib" >> comprp.in;
echo "loadamberparams ./UNK_A23/frcmod.UNK" >> comprp.in;
echo "loadoff ./UNK_A23/UNK.lib" >> comprp.in;
echo "complex = loadpdb complex.pdb" >> comprp.in;
echo "saveamberparm  complex com.prmtop com.inpcrd" >> comprp.in;
echo "savepdb complex com.pdb" >> comprp.in;
echo "quit" >> comprp.in;

tleap -f comprp.in > comprp.out;

echo "**************************************************";
tail -1 comprp.out

echo "--------------------------------------------------";
echo "Complex Parameterization - Done";
echo "**************************************************";
