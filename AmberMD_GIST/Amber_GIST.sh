#!/bin/bash
if [ ! -n "$1" ];then
	echo ""
	echo "This script will perform GIST calculation on the given input PDB"
	echo "Make sure the PDB is prepared before running by removing unwanted water molecules and ligand molecules"
	echo "Example: $0 -p 3tyv.pdb -l UNK.pdb -n 30 -g 0";
	echo "This will perform GIST calculation on 3tyv.pdb for 30 ns (default) timeperiod at 0th gpu card";
	echo
	exit
fi

while getopts p:l:n:g: flag
do
	case "${flag}" in
		p) prt=${OPTARG};;
		l) lig=${OPTARG};;
		n) tp=${OPTARG};;
		g) gpu=${OPTARG};;
	esac
done

# Step1: Generating and Relaxing the Initial Structure

# Preparation of system
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.protein.ff14SB" >> sysprep.in;
echo "source" $AMBERHOME"/dat/leap/cmd/leaprc.water.tip3p" >> sysprep.in;
echo "p = loadpdb $prt" >> sysprep.in;
echo "solvatebox p TIP3PBOX 10" >> sysprep.in;
echo "saveamberparm p rec.prmtop rec.rst7" >> sysprep.in;
echo "quit" >> sysprep.in;

tleap -f sysprep.in > sysprep.out

tail -1 sysprep.out

echo "--------------------------------------------------";
echo "Preparation of $prt - Done";
echo "**************************************************";

# Creating Input files
echo "minimize water" >> min_sys-1.in
echo " &cntrl" >> min_sys-1.in
echo "   imin=1, ntmin=1, nmropt=0, drms=0.1," >> min_sys-1.in
echo "   maxcyc=20000, ncyc=1500," >> min_sys-1.in
echo "   ntx=1,	// not a restart" >> min_sys-1.in
echo "   irest=0," >> min_sys-1.in
echo "   ntpr=100, ntwr=100, iwrap=1," >> min_sys-1.in
echo "   ntf=1,	// SHAKE is off" >> min_sys-1.in
echo "   ntb=1,	 // constant volume pbc" >> min_sys-1.in
echo "   cut=9.0," >> min_sys-1.in
echo "   ntr=1, restraint_wt=100, // Cartesian restraint" >> min_sys-1.in
echo "   restraintmask='!:WAT'," >> min_sys-1.in
echo " /" >> min_sys-1.in


echo "minimize all" >> min_sys-2.in
echo " &cntrl" >> min_sys-2.in
echo "   imin=1, ntmin=1, nmropt=0, drms=0.1," >> min_sys-2.in
echo "   maxcyc=20000, ncyc=1500," >> min_sys-2.in
echo "   ntx=1, irest=0," >> min_sys-2.in
echo "   ntpr=100, ntwr=100, iwrap=1," >> min_sys-2.in
echo "   ntf=1, ntb=1, cut=9.0," >> min_sys-2.in
echo "   ntr=1," >> min_sys-2.in
echo "   restraint_wt=100," >> min_sys-2.in
echo "   restraintmask='!:WAT & !@H'," >> min_sys-2.in
echo " /" >> min_sys-2.in


echo "heat NVT 200ps" >> md-heat-50K.in
echo " &cntrl" >> md-heat-50K.in
echo "  imin = 0," >> md-heat-50K.in
echo "  irest = 0, ntx = 1," >> md-heat-50K.in
echo "  ntb = 1, ntc = 2, ntf = 2," >> md-heat-50K.in
echo "  cut = 9.0," >> md-heat-50K.in
echo "  tempi = 0.0, temp0 = 50.0," >> md-heat-50K.in
echo "  ntt = 3, gamma_ln = 2.0," >> md-heat-50K.in
echo "  nstlim = 10000, dt = 0.002," >> md-heat-50K.in
echo "  iwrap = 1," >> md-heat-50K.in
echo "  ntpr = 1000, ntwx = 1000, ntwr = 10000," >> md-heat-50K.in
echo "  nscm = 1000," >> md-heat-50K.in
echo "  ntr=1, restraint_wt=100," >> md-heat-50K.in
echo "  restraintmask='!:WAT & !@H'," >> md-heat-50K.in
echo "  ig=-1," >> md-heat-50K.in
echo "  ioutfm=1," >> md-heat-50K.in
echo " /" >> md-heat-50K.in


echo "heat NPT 200ps" >> md-heat-300K.in
echo " &cntrl" >> md-heat-300K.in
echo "  imin = 0," >> md-heat-300K.in
echo "  irest = 1, ntx = 5," >> md-heat-300K.in
echo "  ntb = 2, ntc = 2, ntf = 2," >> md-heat-300K.in
echo "  cut = 9.0," >> md-heat-300K.in
echo "  temp0 = 300.0," >> md-heat-300K.in
echo "  ntt = 3, gamma_ln = 2.0," >> md-heat-300K.in
echo "  nstlim = 10000, dt = 0.002," >> md-heat-300K.in
echo "  ntp = 1, taup = 0.5," >> md-heat-300K.in
echo "  iwrap = 1," >> md-heat-300K.in
echo "  ntpr = 1000, ntwx = 1000, ntwr = 10000," >> md-heat-300K.in
echo "  nscm = 1000," >> md-heat-300K.in
echo "  ntr=1, restraint_wt=100," >> md-heat-300K.in
echo "  restraintmask='!:WAT & !@H'," >> md-heat-300K.in
echo "  ig=-1," >> md-heat-300K.in
echo "  ioutfm=1," >> md-heat-300K.in
echo " /" >> md-heat-300K.in


echo "NPT 10ns" >> md-eq-npt-10ns.in
echo " &cntrl" >> md-eq-npt-10ns.in
echo "  imin=0," >> md-eq-npt-10ns.in
echo "  ntpr   = 10000,    ntwx   = 10000," >> md-eq-npt-10ns.in
echo "  ntwr   = 10000," >> md-eq-npt-10ns.in
echo "  iwrap=1," >> md-eq-npt-10ns.in
echo "  ntx=5, irest=1," >> md-eq-npt-10ns.in
echo "  ntf    = 2,       ntb    = 2," >> md-eq-npt-10ns.in
echo "  ntc    = 2,       cut    = 10.0," >> md-eq-npt-10ns.in
echo "  nstlim = 5000000," >> md-eq-npt-10ns.in
echo "  dt     = 0.002," >> md-eq-npt-10ns.in
echo "  nscm   = 1000," >> md-eq-npt-10ns.in
echo "  temp0  = 300.0, tempi = 300.0," >> md-eq-npt-10ns.in
echo "  ntt    = 3, gamma_ln = 2.0," >> md-eq-npt-10ns.in
echo "  ntp    = 1, taup   = 0.5," >> md-eq-npt-10ns.in
echo "  ntr=1, restraint_wt=100," >> md-eq-npt-10ns.in
echo "  restraintmask='!:WAT  & !@H='," >> md-eq-npt-10ns.in
echo "  ig=-1," >> md-eq-npt-10ns.in
echo "  ioutfm=1," >> md-eq-npt-10ns.in
echo " /" >> md-eq-npt-10ns.in

echo "NVT 5ns" >> md-eq-nvt-5ns.in
echo " &cntrl" >> md-eq-nvt-5ns.in
echo "  imin=0," >> md-eq-nvt-5ns.in
echo "  ntpr   = 10000,    ntwx   = 10000," >> md-eq-nvt-5ns.in
echo "  ntwr   = 10000," >> md-eq-nvt-5ns.in
echo "  iwrap=1," >> md-eq-nvt-5ns.in
echo "  ntx=5, irest=1," >> md-eq-nvt-5ns.in
echo "  ntf    = 2,       ntb    = 1," >> md-eq-nvt-5ns.in
echo "  ntc    = 2,       cut    = 9.0," >> md-eq-nvt-5ns.in
echo "  nstlim = 2500000," >> md-eq-nvt-5ns.in
echo "  dt     = 0.002," >> md-eq-nvt-5ns.in
echo "  nscm   = 1000," >> md-eq-nvt-5ns.in
echo "  temp0  = 300.0," >> md-eq-nvt-5ns.in
echo "  ntt    = 3, gamma_ln = 2.0," >> md-eq-nvt-5ns.in
echo "  ntr=1, restraint_wt=100," >> md-eq-nvt-5ns.in
echo "  restraintmask='!:WAT'," >> md-eq-nvt-5ns.in
echo "  ig=-1," >> md-eq-nvt-5ns.in
echo "  ioutfm=1," >> md-eq-nvt-5ns.in
echo " /" >> md-eq-nvt-5ns.in

export CUDA_VISIBLE_DEVICES=$gpu

$AMBERHOME/bin/pmemd -O -i min_sys-1.in -o min1.out -p rec.prmtop -c rec.rst7 -r min_rec-1.rst7
$AMBERHOME/bin/pmemd -O -i min_sys-2.in -o min2.out -p rec.prmtop -c min_rec-1.rst7 -r min_rec-2.rst7 -ref min_rec-1.rst7
$AMBERHOME/bin/pmemd.cuda -O -i md-heat-50K.in -o heat1.out -p rec.prmtop -c min_rec-2.rst7 -r md_heat-50K.rst7 -x heat1.nc -ref min_rec-2.rst7
$AMBERHOME/bin/pmemd.cuda -O -i md-heat-300K.in -o heat2.out -p rec.prmtop -c md_heat-50K.rst7 -r md_heat-300K.rst7 -x heat2.nc -ref md_heat-50K.rst7
$AMBERHOME/bin/pmemd.cuda -O -i md-eq-npt-10ns.in -o equil-npt.out -p rec.prmtop -c md_heat-300K.rst7 -r md_eq-npt.rst7 -x equil-npt.nc -ref md_heat-300K.rst7
$AMBERHOME/bin/pmemd.cuda -O -i md-eq-nvt-5ns.in -o equil-nvt.out -p rec.prmtop -c md_eq-npt.rst7 -r md_eq-nvt.rst7 -x equil-nvt.nc -ref md_eq-npt.rst7


# Step2: Running the MD calculations to collect frames for GIST

## options to choose MD time period (30ns or even longer)
# TimeStep Calculation
x=500000;
y=$tp;
ts=$((x * y));


echo "Production run 1: nvt $tp ns" >> md-nvt-$tp.in
echo " &cntrl" >> md-nvt-$tp.in
echo "  imin=0," >> md-nvt-$tp.in
echo "  ntpr   = 1000,    ntwx   = 1000," >> md-nvt-$tp.in
echo "  ntwr   = 10000," >> md-nvt-$tp.in
echo "  iwrap=1," >> md-nvt-$tp.in
echo "  ntx=5, irest=1," >> md-nvt-$tp.in
echo "  ioutfm = 1," >> md-nvt-$tp.in
echo "  ntf    = 2,       ntb    = 1," >> md-nvt-$tp.in
echo "  ntc    = 2,       cut    = 9.0," >> md-nvt-$tp.in
echo "  nstlim = $ts," >> md-nvt-$tp.in
echo "  dt     = 0.002," >> md-nvt-$tp.in
echo "  nscm   = 1000," >> md-nvt-$tp.in
echo "  temp0  = 300.0," >> md-nvt-$tp.in
echo "  ntt    = 3, gamma_ln = 2.0," >> md-nvt-$tp.in
echo "  ntr=1, restraint_wt=100," >> md-nvt-$tp.in
echo "  restraintmask='!:WAT & !@H'," >> md-nvt-$tp.in
echo "  ig=-1," >> md-nvt-$tp.in
echo " &end" >> md-nvt-$tp.in

# Production Simulation

$AMBERHOME/bin/pmemd.cuda -O -i md-nvt-$tp.in -o md-nvt-$tp.out -p rec.prmtop -c md_eq-nvt.rst7 -r final-prod.rst7 -x prod_gist_$tp.nc -ref md_eq-nvt.rst7

# Step3: Analyzing the MD results with GIST

python3 FindCentroid.py -i $lig > centroid.txt

cent=$(tail -1 centroid.txt)

if [ -f gist.in ];then
	rm gist.in;
fi 

if [ -f gist.out ];then
	rm gist.out;
fi 

echo "parm rec.prmtop" >> gist.in
echo "trajin prod_gist_$tp.nc" >> gist.in
echo "$cent" >> gist.in
echo "go" >> gist.in

cpptraj -i gist.in > gist.out &