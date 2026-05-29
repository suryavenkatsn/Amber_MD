#!/bin/bash
frame=$1

dir=$(basename "$(dirname "$PWD")")

printf "parm ../com-sol1.prmtop
trajin ../prod-all.nc $1 $1 1
reference ../com-sol1.inpcrd
center :1-1326
strip :WAT
strip :Na+
strip :Cl-
trajout $dir-$1.pdb
" > extcluster_$1.in

cpptraj -i extcluster_$1.in > extcluster_$1.out


