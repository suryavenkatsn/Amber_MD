#!/bin/sh
cat rec.pdb | sed '/END/d' > complex.pdb
cat complex.pdb UNKlig.pdb >> complex.pdb
