#!/bin/bash

if [ -f solv.in ] && [ -f complexmin.pdb ];then
	rm solv.in;
	rm complexmin.pdb;
fi

$AMBERHOME/bin/./ambpdb -p com.prmtop -c complexmin.rst > complexmin.pdb

echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> solv.in
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.zinc" >> solv.in
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> solv.in
echo "loadamberparams ./UNK_1/frcmod_1.UNK" >> solv.in
echo "loadamberparams ./UNK_2/frcmod_2.UNK" >> solv.in
echo "loadoff ./UNK_1/UNK_1.lib" >> solv.in
echo "loadoff ./UNK_2/UNK_2.lib" >> solv.in
echo "complex = loadpdb complexmin.pdb" >> solv.in
echo "solvatebox complex TIP3PBOX 10.0" >> solv.in
echo "charge complex" >> solv.in
echo "quit" >> solv.in

cat solv.in

tleap -s -f solv.in > solv.out

echo "**************************************************";
echo "Complex Parameterization is done successfully!";
echo "**************************************************";
