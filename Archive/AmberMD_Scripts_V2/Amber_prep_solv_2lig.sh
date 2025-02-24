#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will solvate and add neutralizing ions in system for MD"
    echo ""
    echo "Usage: $0 <Na+/Cl->"
    echo ""
    echo "Example: $0 Na+"
    echo "This solvate the system with default TIP3PBOX and neutralize with Na+ ions"
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
echo "loadamberparams ./UNK_1/frcmod_1.UNK" >> solv.in
echo "loadamberparams ./UNK_2/frcmod_2.UNK" >> solv.in
echo "loadoff ./UNK_1/UNK_1.lib" >> solv.in
echo "loadoff ./UNK_2/UNK_2.lib" >> solv.in
echo "complex = loadpdb complexmin.pdb" >> solv.in
echo "solvatebox complex TIP3PBOX 10.0" >> solv.in
echo "charge complex" >> solv.in
echo "addIons complex $1 0" >> solv.in
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
