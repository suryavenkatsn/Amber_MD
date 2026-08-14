#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will prepare both protein and ligand files for MD"
    echo ""
    echo "Usage: $0 -p <Protein name> -l <ligand1 name>"
    echo ""
    echo "Example: $0 -p 3tyv.pdb -l UNK.mol2 "
    echo ""
    exit
fi

while getopts p:l: flag
do
	case "${flag}" in
		p) prt=${OPTARG};;
		l) lig=${OPTARG};;
	esac
done


rm -f TotQ_*.txt;
rm -f ligprp_*.in;
rm -f ligprp_*.out;

if [ ! -f $prt ];then
	echo "$prt is not found";
	exit;
fi

if [ ! -f $lig ]; then
	echo "$lig is not found";
	exit;
fi

# splits ligand input name and its format extension
ligand=$(echo "$lig" | awk -F '[.]' '{ print $1 }')
# Extract charge from the input ligand file
grep -A 1 'i_epik_Tot_Q' $ligand.sdf >> TotQ_$ligand.txt
charge=$(tail -1 TotQ_$ligand.txt)

echo ""
echo "--------------------------------------------------";
echo "Name of the Protein: $prt ";
echo "Name of the Ligand: $lig ";
echo "Charge of the Ligand: $charge ";
echo "--------------------------------------------------";


mkdir UNK_$ligand
cd UNK_$ligand

antechamber -i ../$ligand.mol2 -fi mol2 -o $ligand-ac.mol2 -fo mol2 -nc $charge -c bcc -dr no;

$AMBERHOME/bin/./parmchk2 -i $ligand-ac.mol2 -f mol2 -o frcmod.UNK;


echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff14SB" >> ligprp_$ligand.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> ligprp_$ligand.in;
echo "UNK = loadmol2 $ligand-ac.mol2" >> ligprp_$ligand.in;
echo "check UNK" >> ligprp_$ligand.in;
echo "loadamberparams frcmod.UNK" >> ligprp_$ligand.in;
echo "saveoff UNK UNK.lib" >> ligprp_$ligand.in;
echo "saveamberparm UNK UNK.prmtop UNK.inpcrd" >> ligprp_$ligand.in;
echo "savepdb UNK UNKlig.pdb" >> ligprp_$ligand.in;
echo "quit" >> ligprp_$ligand.in;

tleap -f ligprp_$ligand.in > ligprp_$ligand.out;

echo "";

tail -1 ligprp_$ligand.out

echo "--------------------------------------------------";
echo "Parameterization of $ligand - Done";
echo "**************************************************";

cd ../

# Python Check

ver=$(python3 -V 2>&1 | sed 's/.* \([0-9]\).\([0-9]\).*/\1\2/')
if [ $ver -lt 30 ];then
	echo "Upgrade the Python to version greater than 3.0"
	echo ""
	exit
fi

# Protein Preparation

rm -f prtprp.in;
rm -f prtprp.out;

echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff14SB" >> prtprp.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.zinc" >> prtprp.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> prtprp.in;
echo "pro = loadpdb $prt" >> prtprp.in;
echo "saveamberparm pro rec.prmtop rec.inpcrd" >> prtprp.in;
echo "savepdb  pro rec.pdb" >> prtprp.in;
echo "quit" >> prtprp.in;

tleap -f prtprp.in > prtprp.out;

echo "**************************************************";
tail -1 prtprp.out


echo "--------------------------------------------------";
echo "Protein Parameterization - Done!";
echo "**************************************************";

# Complex Preparation

rm -f comprp.in;
rm -f comprp.out;
rm -f complex.pdb;


cat rec.pdb | sed '/END/d' > rec1.pdb;
cat rec1.pdb ./UNK_$ligand/UNKlig.pdb >> complex.pdb;
rm rec1.pdb

echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff14SB" >> comprp.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.zinc" >> comprp.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> comprp.in;
echo "loadamberparams ./UNK_$ligand/frcmod.UNK" >> comprp.in;
echo "loadoff ./UNK_$ligand/UNK.lib" >> comprp.in;
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


# Input files generation for ligand and complex minimization

lignum=$(awk '/UNK/ { print $5;exit; }' com.pdb);
recstart=1
recend=$((lignum - 1))


echo "----------------------INPUTS----------------------";
echo "Protein Start: $recstart ";
echo "Protein End: $recend ";
echo "Ligand No.: $lignum ";
echo "--------------------------------------------------";
echo "---------------INPUT FILES CREATED--------------- ";

rm -f drug.in;
rm -f complexmin.in;

# Input file for Ligand Minimization
echo "Minimize drug coords (drug is resid $ligstart) and xtal water" >> drug.in;
echo " &cntrl" >> drug.in;
echo "  imin = 1," >> drug.in;
echo "  maxcyc = 1000," >> drug.in;
echo "  ncyc = 500," >> drug.in;
echo "  ntr = 1," >> drug.in;
echo "  ntb = 0," >> drug.in;
echo "  cut = 16.0," >> drug.in;
echo "/" >> drug.in;
echo "Keep protein fixed" >> drug.in;
echo "10.0" >> drug.in
echo "RES $recstart $recend" >> drug.in;
echo "END" >> drug.in;
echo "END" >> drug.in;


# Input file for Complex Minimization

echo "Minimize water positions (and all hydrogens)" >> complexmin.in;
echo " &cntrl" >> complexmin.in;
echo "  imin = 1," >> complexmin.in;
echo "  maxcyc = 1000," >> complexmin.in;
echo "  ncyc = 500," >> complexmin.in
echo "  ntr = 1," >> complexmin.in
echo "  ntb = 0,cut=16.0," >> complexmin.in
echo "/" >> complexmin.in;
echo "END" >> complexmin.in;


# Running Ligand and Complex Minimization

if [ ! -f drug.in ] && [ ! -f complexmin.in ];then
	echo "***One or more input files are not available. Please ensure all the input files are in place before running minimization***"
	exit
fi


sander -O -i drug.in -o drug.out -p com.prmtop -c com.inpcrd -r drug.rst -x drug.mdcrd -ref com.inpcrd
sander -O -i complexmin.in -o complexmin.out -p com.prmtop -c drug.rst -r complexmin.rst -x complexmin.mdcrd -ref drug.rst

# Estimation of charge and volume of system

rm -f solv_c.in;
rm -f solv_charge.out;
rm -r complexmin.pdb;

$AMBERHOME/bin/./ambpdb -p com.prmtop -c complexmin.rst > complexmin.pdb

echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff14SB" >> solv_c.in
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.zinc" >> solv_c.in
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> solv_c.in
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.water.tip3p" >> solv_c.in
echo "loadamberparams ./UNK_$ligand/frcmod.UNK" >> solv_c.in
echo "loadoff ./UNK_$ligand/UNK.lib" >> solv_c.in
echo "complex = loadpdb complexmin.pdb" >> solv_c.in
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

rm -f solv.in;
rm -f solv.out;
rm -f complexmin.pdb;


$AMBERHOME/bin/./ambpdb -p com.prmtop -c complexmin.rst > complexmin.pdb

echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff14SB" >> solv.in
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.zinc" >> solv.in
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> solv.in
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.water.tip3p" >> solv.in
echo "loadamberparams ./UNK_$ligand/frcmod.UNK" >> solv.in
echo "loadoff ./UNK_$ligand/UNK.lib" >> solv.in
echo "complex = loadpdb complexmin.pdb" >> solv.in
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
