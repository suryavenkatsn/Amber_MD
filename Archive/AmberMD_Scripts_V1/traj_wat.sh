#!/bin/sh

cpptraj com-sol1.prmtop <<EOF
trajin prod1.nc 0 10000000 10
reference equil1.rst
center :1-1112
autoimage
closest 20 :1112 first
rms reference out protienrms :1-1111,@CA,C,N,O
rms reference out ligrms1-min :1112 nofit
strip :Na+
strip :Cl-
trajout traj-20WAT.pdb pdb append
EOF
