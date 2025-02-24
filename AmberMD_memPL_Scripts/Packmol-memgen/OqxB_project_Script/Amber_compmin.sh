#!/bin/bash

if [ -f drug.in ];then
        rm drug.in;
fi

if [ -f complexmin.in ];then
        rm complexmin.in;
fi

# Input file for Ligand Minimization
echo "Minimize drug coords and xtal water" >> drug.in;
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
echo "RES 1 3126" >> drug.in;
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

# Running Ligand and Complex Minimization

if [ ! -f drug.in ] && [ ! -f complexmin.in ];then
	echo "***One or more input files are not available. Please ensure all the input files are in place before running minimization***"
	exit
fi


sander -O -i drug.in -o drug.out -p com.prmtop -c com.inpcrd -r drug.rst -x drug.mdcrd -ref com.inpcrd
sander -O -i complexmin.in -o complexmin.out -p com.prmtop -c drug.rst -r complexmin.rst -x complexmin.mdcrd -ref drug.rst

$AMBERHOME/bin/./ambpdb -p com.prmtop -c complexmin.rst > complexmin.pdb
