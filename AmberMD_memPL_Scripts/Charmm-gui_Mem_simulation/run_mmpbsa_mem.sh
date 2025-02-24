#!/bin/sh
$AMBERHOME/bin/ante-MMPBSA.py -p ../step5_input.parm7 -c com1.prmtop -r rec1.prmtop -l UNK1.prmtop -s ':Na+,Cl-,WAT,PA,PC,OL' -n ':$lignum' --radii=mbondi3
$AMBERHOME/bin/MMPBSA.py -O -i mmpbsa_mem.in -o FINAL_RESULTS_MMPBSA.dat -do FINAL_DECOMP_MMPBSA.dat -sp ../step5_input.parm7 -cp com1.prmtop -rp rec1.prmtop -lp UNK1.prmtop -y ../step7_production.nc