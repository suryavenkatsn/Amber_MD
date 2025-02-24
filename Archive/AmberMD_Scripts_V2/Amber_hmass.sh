#!/bin/bash
echo "**************************************************";
echo Hydrogen Mass Repartitioning Initiated;
echo "**************************************************";

if [ -f hmass.in ];then
	rm hmass.in
fi

echo "hmassrepartition 3" >> hmass.in;
echo "outparm com-sol1_hmass.prmtop" >> hmass.in;
echo "quit" >> hmass.in;

cat hmass.in

parmed -p com-sol1.prmtop -i hmass.in > hmass.out

echo ""

tail -l hmass.out

echo ""

echo "**************************************************";
echo "Hydrogen Mass Repartitioning is done successfully!";
echo "**************************************************";
