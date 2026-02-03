#!/bin/bash
if [ ! -n "$1" ];then
	echo ""
	echo "This script will perform GIST calculation on the input trajectory"
	echo "Example: $0 prod1.nc UNKlig.pdb";
	echo "This will perform GIST calculation on "prod1.nc" using centroid of "UNKlig.pdb"";
	echo
	exit
fi

cp $2 UNK.pdb
sed -i '/TER/d' UNK.pdb
sed -i '/END/d' UNK.pdb

# Analyzing the MD results with GIST
python3 FindCentroid.py -i UNK.pdb > centroid.txt

cent=$(tail -1 centroid.txt)

printf "parm ../com-sol1.prmtop
trajin $1 5000 last 10
$cent
go " > gist.in

cpptraj -p ../rec.prmtop -i gist.in > gist.out