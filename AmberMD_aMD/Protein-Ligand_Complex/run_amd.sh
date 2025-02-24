# $AMBERHOME/bin/pmemd.cuda -O -i amd.in -o amd.out -p mem_syst.prmtop -c 07_NPT_7xz9_2.rst -r prod_amd.nc

export CUDA_VISIBLE_DEVICES=$1

$AMBERHOME/bin/pmemd.cuda -O -i amd.in -o amd.out -p com-sol1.prmtop -c equil.rst -r prod_amd.rst -x prod_amd.nc -inf prod_amd.mdinfo -ref equil.rst