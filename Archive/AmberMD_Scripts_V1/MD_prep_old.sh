#!/bin/bash
while getopts p:u:c:g: flag
do
	case "${flag}" in
		p) protein=${OPTARG};;
		u) ligand=${OPTARG};;
		c) charge=${OPTARG};;
		g) cuda=${OPTARG};;
	esac
done
echo Name of the Protein: $protein;
echo Name of the Ligand: $ligand;
echo Charge of the Ligand: $charge;
echo Selected CUDA_VISIBLE_DEVICES: $cuda;

rm prtprp.in
rm ligprp.in
rm comprp.in

$AMBERHOME

# Protein Parameterization
echo "source" $AMBERHOME"dat/leap/cmd/oldff/leaprc.ff99SB" >> prtprp.in
echo "source" $AMBERHOME"dat/leap/cmd/leaprc.gaff" >> prtprp.in
echo "pro = loadpdb $protein.pdb" >> prtprp.in
echo "saveamberparm pro rec.prmtop rec.inpcrd" >> prtprp.in
echo "savepdb  pro rec.pdb" >> prtprp.in
echo "quit" >> prtprp.in

cat prtprp.in

tleap -f prtprp.in

echo "Protein Parameterization is done successfully!"

# Ligand Parameterization

antechamber -i $ligand.mol2 -fi mol2 -o $ligand-ac.mol2 -fo mol2 -nc $charge -c bcc -dr no

$AMBERHOME/bin/./parmchk2 -i $ligand-ac.mol2 -f mol2 -o frcmod.UNK

echo "source" $AMBERHOME"dat/leap/cmd/oldff/leaprc.ff99SB" >> ligprp.in
echo "source" $AMBERHOME"dat/leap/cmd/leaprc.gaff" >> ligprp.in
echo "UNK = loadmol2 $ligand-ac.mol2" >> ligprp.in
echo "check UNK" >> ligprp.in
echo "loadamberparams frcmod.UNK" >> ligprp.in
echo "saveoff UNK UNK.lib" >> ligprp.in
echo "saveamberparm UNK UNK.prmtop UNK.inpcrd" >> ligprp.in
echo "savepdb UNK UNKlig.pdb" >> ligprp.in
echo "quit" >> ligprp.in

cat ligprp.in

tleap -f ligprp.in

echo "Ligand Parameterization is done successfully!"

# Complex Formation

cat rec.pdb | sed '/END/d' > complex.pdb
cat complex.pdb UNKlig.pdb >> complex.pdb



echo "source" $AMBERHOME"dat/leap/cmd/oldff/leaprc.ff99SB" >> comprp.in
echo "source" $AMBERHOME"dat/leap/cmd/leaprc.gaff" >> comprp.in
echo "loadamberparams frcmod.UNK" >> comprp.in
echo "loadoff UNK.lib" >> comprp.in
echo "complex = loadpdb complex.pdb" >> comprp.in
echo "saveamberparm  complex com.prmtop com.inpcrd" >> comprp.in
echo "savepdb complex com.pdb" >> comprp.in
echo "quit" >> comprp.in

cat comprp.in

tleap -f comprp.in


echo "Complex Parameterization is done successfully!"

