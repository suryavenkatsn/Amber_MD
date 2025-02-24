#!/bin/bash

if [ -f complex.pdb ];then
	rm complex.pdb;
fi

cat rec.pdb | sed '/END/d' > rec1.pdb;
cat rec1.pdb ./UNK_1/UNKlig_1.pdb >> comp1.pdb;
cat comp1.pdb | sed '/END/d' > comp2.pdb;
cat comp2.pdb ./UNK_2/UNKlig_2.pdb >> complex.pdb;

rm rec1.pdb
rm comp1.pdb;
rm comp2.pdb;