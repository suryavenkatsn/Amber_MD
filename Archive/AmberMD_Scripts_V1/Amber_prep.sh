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
echo Selected CUDA_VIISBLE_DEVICES: $cuda;
echo "**************************************************";
echo "_______________Select the Operation_______________";
echo "**************************************************";
echo " 1) Protein Parameterization";
echo " 2) Antechamber - Ligand Parameterization";
echo " 3) Ligand Parameterization";
echo " 4) Complex Parameterization";
echo " 5) Parameterization for Ligand and Complex";
echo " 6) Parameterization for Protein, Ligand & Complex";
echo "**************************************************";

read n

case $n in
	1) rm prtprp.in;
		echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> prtprp.in;
		echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> prtprp.in;
		echo "pro = loadpdb $protein.pdb" >> prtprp.in;
		echo "saveamberparm pro rec.prmtop rec.inpcrd" >> prtprp.in;
		echo "savepdb  pro rec.pdb" >> prtprp.in;
		echo "quit" >> prtprp.in;
		
		cat prtprp.in;
		
		tleap -f prtprp.in;
		
		echo "**************************************************";
		echo "Protein Parameterization is done successfully!";
		echo "**************************************************";
	;;
		
	2)  antechamber -i $ligand.mol2 -fi mol2 -o $ligand-ac.mol2 -fo mol2 -nc $charge -c bcc -dr no;
		$AMBERHOME/bin/./parmchk2 -i $ligand-ac.mol2 -f mol2 -o frcmod.UNK;
	;;
	3) rm ligprp.in;
		echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> ligprp.in;
		echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> ligprp.in;
		echo "UNK = loadmol2 $ligand-ac.mol2" >> ligprp.in;
		echo "check UNK" >> ligprp.in;
		echo "loadamberparams frcmod.UNK" >> ligprp.in;
		echo "saveoff UNK UNK.lib" >> ligprp.in;
		echo "saveamberparm UNK UNK.prmtop UNK.inpcrd" >> ligprp.in;
		echo "savepdb UNK UNKlig.pdb" >> ligprp.in;
		echo "quit" >> ligprp.in;

		cat ligprp.in;

		tleap -f ligprp.in;
		
		echo "**************************************************";
		echo "Ligand Parameterization is done successfully!";
		echo "**************************************************";
	;;
	4) rm comprp.in;
		rm complex.pdb;
		cat rec.pdb | sed '/END/d' > complex.pdb;
		cat complex.pdb UNKlig.pdb >> complex.pdb;
		echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> comprp.in;
		echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> comprp.in;
		echo "loadamberparams frcmod.UNK" >> comprp.in;
		echo "loadoff UNK.lib" >> comprp.in;
		echo "complex = loadpdb complex.pdb" >> comprp.in;
		echo "saveamberparm  complex com.prmtop com.inpcrd" >> comprp.in;
		echo "savepdb complex com.pdb" >> comprp.in;
		echo "quit" >> comprp.in;

		cat comprp.in;

		tleap -f comprp.in;
		
		echo "**************************************************";
		echo "Complex Parameterization is done successfully!";
		echo "**************************************************";
	;;
	5) rm ligprp.in;
		antechamber -i $ligand.mol2 -fi mol2 -o $ligand-ac.mol2 -fo mol2 -nc $charge -c bcc -dr no;
		$AMBERHOME/bin/./parmchk2 -i $ligand-ac.mol2 -f mol2 -o frcmod.UNK;
		echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> ligprp.in;
		echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> ligprp.in;
		echo "UNK = loadmol2 $ligand-ac.mol2" >> ligprp.in;
		echo "check UNK" >> ligprp.in;
		echo "loadamberparams frcmod.UNK" >> ligprp.in;
		echo "saveoff UNK UNK.lib" >> ligprp.in;
		echo "saveamberparm UNK UNK.prmtop UNK.inpcrd" >> ligprp.in;
		echo "savepdb UNK UNKlig.pdb" >> ligprp.in;
		echo "quit" >> ligprp.in;

		cat ligprp.in;

		tleap -f ligprp.in;
		
		echo "**************************************************";
		echo "Ligand Parameterization is done successfully!";
		echo "**************************************************";
		
		rm comprp.in;
		rm complex.pdb;
		cat rec.pdb | sed '/END/d' > complex.pdb;
		cat complex.pdb UNKlig.pdb >> complex.pdb;
		echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> comprp.in;
		echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> comprp.in;
		echo "loadamberparams frcmod.UNK" >> comprp.in;
		echo "loadoff UNK.lib" >> comprp.in;
		echo "complex = loadpdb complex.pdb" >> comprp.in;
		echo "saveamberparm  complex com.prmtop com.inpcrd" >> comprp.in;
		echo "savepdb complex com.pdb" >> comprp.in;
		echo "quit" >> comprp.in;

		cat comprp.in;

		tleap -f comprp.in;
		
		echo "**************************************************";
		echo "Complex Parameterization is done successfully!";
		echo "**************************************************";
	;;
	6) rm prtprp.in;
		echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> prtprp.in;
		echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> prtprp.in;
		echo "pro = loadpdb $protein.pdb" >> prtprp.in;
		echo "saveamberparm pro rec.prmtop rec.inpcrd" >> prtprp.in;
		echo "savepdb  pro rec.pdb" >> prtprp.in;
		echo "quit" >> prtprp.in;
		
		cat prtprp.in;
		
		tleap -f prtprp.in;
		
		echo "**************************************************";
		echo "Protein Parameterization is done successfully!";
		echo "**************************************************";
		
		rm ligprp.in;
		antechamber -i $ligand.mol2 -fi mol2 -o $ligand-ac.mol2 -fo mol2 -nc $charge -c bcc -dr no;
		$AMBERHOME/bin/./parmchk2 -i $ligand-ac.mol2 -f mol2 -o frcmod.UNK;
		echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> ligprp.in;
		echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> ligprp.in;
		echo "UNK = loadmol2 $ligand-ac.mol2" >> ligprp.in;
		echo "check UNK" >> ligprp.in;
		echo "loadamberparams frcmod.UNK" >> ligprp.in;
		echo "saveoff UNK UNK.lib" >> ligprp.in;
		echo "saveamberparm UNK UNK.prmtop UNK.inpcrd" >> ligprp.in;
		echo "savepdb UNK UNKlig.pdb" >> ligprp.in;
		echo "quit" >> ligprp.in;

		cat ligprp.in;

		tleap -f ligprp.in;
		
		echo "**************************************************";
		echo "Ligand Parameterization is done successfully!";
		echo "**************************************************";
		
		rm comprp.in;
		rm complex.pdb;
		cat rec.pdb | sed '/END/d' > complex.pdb;
		cat complex.pdb UNKlig.pdb >> complex.pdb;
		echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> comprp.in;
		echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> comprp.in;
		echo "loadamberparams frcmod.UNK" >> comprp.in;
		echo "loadoff UNK.lib" >> comprp.in;
		echo "complex = loadpdb complex.pdb" >> comprp.in;
		echo "saveamberparm  complex com.prmtop com.inpcrd" >> comprp.in;
		echo "savepdb complex com.pdb" >> comprp.in;
		echo "quit" >> comprp.in;

		cat comprp.in;

		tleap -f comprp.in;
		
		echo "**************************************************";
		echo "Complex Parameterization is done successfully!";
		echo "**************************************************";
	;;
	*) echo "Invalid Option";;
esac


