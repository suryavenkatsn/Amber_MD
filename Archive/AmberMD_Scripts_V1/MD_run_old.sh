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

$AMBERHOME

# Protein Parameterization
echo "source /home/surya/amber18/dat/leap/cmd/oldff/leaprc.ff99SB" >> prtprp.in
echo "source /home/surya/amber18/dat/leap/cmd/leaprc.gaff" >> prtprp.in
echo "pro = loadpdb $protein.pdb" >> prtprp.in
echo "saveamberparm pro rec.prmtop rec.inpcrd" >> prtprp.in
echo "savepdb  pro rec.pdb" >> prtprp.in
echo "quit" >> prtprp.in

cat prtprp.in

tleap -f prtprp.in


# Ligand Parameterization

antechamber -i $ligand.mol2 -fi mol2 -o $ligand-ac.mol2 -fo mol2 -nc $charge -c bcc -dr no

$AMBERHOME/bin/./parmchk2 -i $ligand-ac.mol2 -f mol2 -o frcmod.UNK

echo "source /home/surya/amber18/dat/leap/cmd/oldff/leaprc.ff99SB" >> ligprp.in
echo "source /home/surya/amber18/dat/leap/cmd/leaprc.gaff" >> ligprp.in
echo "UNK = loadmol2 $ligand-ac.mol2" >> ligprp.in
echo "check UNK" >> ligprp.in
echo "loadamberparams frcmod.UNK" >> ligprp.in
echo "saveoff UNK UNK.lib" >> ligprp.in
echo "saveamberparm UNK UNK.prmtop UNK.inpcrd" >> ligprp.in
echo "savepdb UNK UNKlig.pdb" >> ligprp.in
echo "quit" >> ligprp.in

cat ligprp.in

tleap -f ligprp.in

# Complex Formation

cat rec.pdb | sed '/END/d' > complex.pdb
cat complex.pdb UNKlig.pdb >> complex.pdb

echo "Complex Parameterization is done successfully!"

# Complex Minimization

# sh ./int.sh &

sander -O -i drug.in -o drug.out -p com.prmtop -c com.inpcrd -r drug.rst -x drug.mdcrd -ref com.inpcrd
sander -O -i complexmin.in -o complexmin.out -p com.prmtop -c drug.rst -r complexmin.rst -x complexmin.mdcrd -ref drug.rst

echo "Complex Minimization is done successfully!"


# Minimized complex pdb file
$AMBERHOME/bin/./ambpdb -p com.prmtop -c complexmin.rst > complexmin.pdb

# Solvation and Addition of Ions
echo "source /opt/amber18/dat/leap/cmd/oldff/leaprc.ff99SB" >> solv.in
echo "source /opt/amber18/dat/leap/cmd/leaprc.gaff" >> solv.in
echo "loadamberparams frcmod.UNK" >> solv.in
echo "loadoff UNK.lib" >> solv.in
echo "complex = loadpdb complexmin.pdb" >> solv.in
echo "solvatebox complex TIP3PBOX 10.0" >> solv.in
echo "charge complex" >> solv.in
echo "addIons complex Cl- 0" >> solv.in
echo "saveamberparm complex com-sol1.prmtop com-sol1.inpcrd" >> solv.in
echo "savepdb complex com-sol1.pdb" >> solv.in

cat solv.in

tleap -f solv.in

echo "Solvation and Addition of Ions are completed successfully!"

# Production Run
export CUDA_VISIBLE_DEVICES=$cuda

# sh ./fin.sh &

pmemd.cuda -O -i watermin.in -o watermin.out -p com-sol1.prmtop -c com-sol1.inpcrd -r watermin.rst -ref com-sol1.inpcrd
pmemd.cuda  -O -i min.in -o min.out -p com-sol1.prmtop -c watermin.rst -r min.rst -x min.mdcrd -ref watermin.rst
pmemd.cuda -O -i heat.in -o heat.out -p com-sol1.prmtop -c min.rst -r heat.rst -x heat.mdcrd -ref min.rst
pmemd.cuda -O -i heat1.in -o heat1.out -p com-sol1.prmtop -c heat.rst -r heat1.rst -x heat1.mdcrd -ref heat.rst
pmemd.cuda -O -i densi.in -o densi.out -p com-sol1.prmtop -c heat1.rst -r density.rst -x densi.nc -ref heat1.rst
pmemd.cuda -O -i equil.in -o equil.out -p com-sol1.prmtop -c density.rst -r equil.rst -x equil.nc -ref density.rst
pmemd.cuda -O -i equil1.in -o equil1.out -p com-sol1.prmtop -c equil.rst -r equil1.rst -x equil1.nc -ref equil.rst
pmemd.cuda -O -i prod.in -o prod1.out -p com-sol1.prmtop -c equil1.rst -r prod1.rst -x prod1.nc -ref equil1.rst

cat mdinfo

echo "Production Run is completed!"