$AMBERHOME/bin/pmemd -O -i min_sys-1.in -o min1.out -p fxa.prmtop -c fxa.rst7 -r min_fxa-1.rst7


$AMBERHOME/bin/pmemd -O -i min_sys-2.in -o min2.out -p fxa.prmtop -c min_fxa-1.rst7 -r min_fxa-2.rst7 -ref min_fxa-1.rst7


$AMBERHOME/bin/pmemd.cuda -O -i md-heat-50K.in -o heat1.out -p fxa.prmtop -c min_fxa-2.rst7 -r md_heat-50K.rst7 -x heat1.nc -ref min_fxa-2.rst7


$AMBERHOME/bin/pmemd.cuda -O -i md-heat-300K.in -o heat2.out -p fxa.prmtop -c md_heat-50K.rst7 -r md_heat-300K.rst7 -x heat2.nc -ref md_heat-50K.rst7


$AMBERHOME/bin/pmemd.cuda -O -i md-eq-npt-10ns.in -o equil-npt.out -p fxa.prmtop -c md_heat-300K.rst7 -r md_eq-npt.rst7 -x equil-npt.nc -ref md_heat-300K.rst7


$AMBERHOME/bin/pmemd.cuda -O -i md-eq-nvt-5ns.in -o equil-nvt.out -p fxa.prmtop -c md_eq-npt.rst7 -r md_eq-nvt.rst7 -x equil-nvt.nc -ref md_eq-npt.rst7