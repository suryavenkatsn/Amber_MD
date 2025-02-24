#!/bin/bash

if [ -f solv_c.in ];then
	rm solv_c.in;
fi 

if [ -f solv_charge.out ];then
	rm solv_charge.out;
fi 

if [ -f prtmin.pdb ];then
        rm prtmin.pdb;
fi

$AMBERHOME/bin/./ambpdb -p rec.prmtop -c prtmin.rst > prtmin.pdb

echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> solv_c.in
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.zinc" >> solv_c.in
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> solv_c.in
# echo "loadamberparams ./UNK_$ligand/frcmod.UNK" >> solv_c.in
# echo "loadoff ./UNK_$ligand/UNK.lib" >> solv_c.in
echo "complex = loadpdb prtmin.pdb" >> solv_c.in
echo "solvatebox complex TIP3PBOX 10.0" >> solv_c.in
echo "charge complex" >> solv_c.in
echo "quit" >> solv_c.in

tleap -f solv_c.in > solv_charge.out


charge=$(awk '/Total unperturbed charge/ { print $4;exit; }' leap.log);
vol=$(awk '/Volume/ { print $2;exit; }' leap.log);


# Calculation using python
python3 ions_nacl.py -i $charge >> ions.txt
python3 sc_calcs.py -v $vol >> sc.txt

ion=$(tail -1 ions.txt)
nacl=$(tail -1 sc.txt)

# Solvation of the System
if [ -f solv.in ];then
        rm solv.in;
fi

if [ -f solv.out ];then
        rm solv.out;
fi

if [ -f prtmin.pdb ];then
        rm prtmin.pdb;
fi


$AMBERHOME/bin/./ambpdb -p rec.prmtop -c prtmin.rst > prtmin.pdb

echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> solv.in
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.zinc" >> solv.in
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> solv.in
echo "complex = loadpdb prtmin.pdb" >> solv.in
echo "solvatebox complex TIP3PBOX 10.0" >> solv.in
echo "charge complex" >> solv.in
echo "addIons complex $ion 0" >> solv.in
echo "addIonsRand complex Na+ $nacl Cl- $nacl" >> solv.in
echo "saveamberparm complex com-sol1.prmtop com-sol1.inpcrd" >> solv.in
echo "savepdb complex com-sol1.pdb" >> solv.in
echo "quit" >> solv.in


tleap -f solv.in > solv.out

echo "**************************************************";
tail -1 solv.out


echo "--------------------------------------------------";
echo "Complex Solvation - Done";
echo "Check the solvated system and run MD simulation";
echo "**************************************************";
