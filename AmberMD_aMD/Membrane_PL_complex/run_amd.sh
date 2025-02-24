# $AMBERHOME/bin/pmemd.cuda -O -i amd.in -o amd.out -p mem_syst.prmtop -c 07_NPT_7xz9_2.rst -r prod_amd.nc

$AMBERHOME/bin/pmemd.cuda -O -i amd.in -o amd.out -p step5_input.parm7 -c step6.6_equilibration.rst7 -r prod_amd.rst -x prod_amd.nc -inf prod_amd.mdinfo