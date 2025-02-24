#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will parameterize and prepare protein files for MD"
    echo ""
    echo "Usage: $0 <protein name>"
    echo ""
    echo "Example: $0 3tyv.pdb"
    echo "This will parameterize the protein"
    echo ""
    exit
fi

echo "**************************************************";
echo Name of the Protein: $1;
echo "**************************************************";

rm prtprp.in;


echo "source" $AMBERHOME"/dat/leap/cmd/oldff/leaprc.ff99SB" >> prtprp.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.zinc" >> prtprp.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.gaff" >> prtprp.in;
echo "pro = loadpdb $1" >> prtprp.in;
echo "saveamberparm pro rec.prmtop rec.inpcrd" >> prtprp.in;
echo "savepdb  pro rec.pdb" >> prtprp.in;
echo "quit" >> prtprp.in;

cat prtprp.in;

tleap -f prtprp.in > prtprp.out;

echo "";

tail -1 prtprp.out

echo "";

echo "**************************************************";
echo "Protein Parameterization is done successfully!";
echo "**************************************************";

# Input files generation for ligand and complex minimization

recend=$(tail -3 rec.pdb | awk '/ATOM/ { print $5;exit; }');
recstart=1


echo "----------------------INPUTS----------------------";
echo "Protein Start: $recstart ";
echo "Protein End: $recend ";
echo "--------------------------------------------------";
echo "---------------INPUT FILES CREATED--------------- ";


if [ -f drug.in ];then
        rm drug.in;
fi

if [ -f complexmin.in ];then
        rm complexmin.in;
fi

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

if [ -f "drug.in" ];then
        echo "drug.in - Done"
else
        echo "drug.in - Not Done"
fi


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

if [ -f "complexmin.in" ];then
        echo "complexmin.in - Done"
else
        echo "complexmin.in - Not Done"
fi