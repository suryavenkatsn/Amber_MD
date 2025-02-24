#!/bin/bash

if [ -f solv_c.in ];then
	rm solv_c.in;
fi 

if [ -f complexmin.pdb ];then
	rm complexmin.pdb;
fi

$AMBERHOME/bin/./ambpdb -p com.prmtop -c complexmin.rst > complexmin.pdb

echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> solv_c.in
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.zinc" >> solv_c.in
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> solv_c.in
echo "loadamberparams frcmod.UNK" >> solv_c.in
echo "loadoff UNK.lib" >> solv_c.in
echo "complex = loadpdb complexmin.pdb" >> solv_c.in
echo "solvatebox complex TIP3PBOX 10.0" >> solv_c.in
echo "charge complex" >> solv_c.in
echo "quit" >> solv_c.in

echo ""
echo "===================================================="
cat solv_c.in
echo "===================================================="

tleap -f solv_c.in > solv_charge.out

echo ""
echo "****************************************************"
grep -i 'Total unperturbed charge' leap.log
echo "****************************************************"

echo ""
echo "****************************************************"
grep -i 'volume' leap.log
echo "****************************************************"
echo ""



