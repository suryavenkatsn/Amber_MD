#!/bin/sh
cpptraj com-sol1.prmtop <<EOF
trajin prod1.nc 0 10000000 10
reference equil1.rst
center :1-1112
rms reference out protienrms.agr :1-1111,@CA,C,N,O
rms reference out ligrms1-min.agr :1112 nofit
strip :Na+
strip :Cl-
strip :WAT
trajout traj.pdb pdb append
EOF
