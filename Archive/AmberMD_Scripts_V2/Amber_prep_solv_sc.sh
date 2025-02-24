#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will solvate and add neutralizing ions in system for MD"
    echo ""
    echo "Usage: $0 <Na+/Cl-> <No. of Ions>"
    echo ""
    echo "Example: $0 Na+ 19"
    echo "This solvate the system with default TIP3PBOX, neutralize with Na+ ions and add 19 Na+ & Cl- ions to keep salt concentration at 0.15 mM"
    echo ""
    exit
fi

rm solv.in;
rm complexmin.pdb;


echo "**************************************************";
echo Selected Ion to neutralize the system: $1;
echo "**************************************************";


$AMBERHOME/bin/./ambpdb -p com.prmtop -c complexmin.rst > complexmin.pdb

echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> solv.in
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.zinc" >> solv.in
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> solv.in
echo "loadamberparams frcmod.UNK" >> solv.in
echo "loadoff UNK.lib" >> solv.in
echo "complex = loadpdb complexmin.pdb" >> solv.in
echo "solvatebox complex TIP3PBOX 10.0" >> solv.in
echo "charge complex" >> solv.in
echo "addIons complex $1 0" >> solv.in
echo "addIonsRand complex Na+ $2 Cl- $2" >> solv.in
echo "saveamberparm complex com-sol1.prmtop com-sol1.inpcrd" >> solv.in
echo "savepdb complex com-sol1.pdb" >> solv.in
echo "quit" >> solv.in

cat solv.in

tleap -f solv.in > solv.out

echo "";

tail -1 solv.out

echo "";

echo "**************************************************";
echo "Complex Solvation is done successfully!";
echo "**************************************************";
