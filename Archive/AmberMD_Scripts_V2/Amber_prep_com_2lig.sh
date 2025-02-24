#!/bin/bash

if [ -f comprp.in ];then
	rm comprp.in;
fi


echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> comprp.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> comprp.in;
echo "loadamberparams ./UNK_1/frcmod_1.UNK" >> comprp.in;
echo "loadamberparams ./UNK_2/frcmod_2.UNK" >> comprp.in;
echo "loadoff ./UNK_1/UNK_1.lib" >> comprp.in;
echo "loadoff ./UNK_2/UNK_2.lib" >> comprp.in;
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
