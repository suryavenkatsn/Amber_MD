#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "Usage: $0 <20ns>"
    echo "Example: $0 20"
    echo ""
    exit
fi

# Python Check

ver=$(python3 -V 2>&1 | sed 's/.* \([0-9]\).\([0-9]\).*/\1\2/')
if [ $ver -lt 30 ];then
	echo "Upgrade the Python to version greater than 3.0"
	echo ""
	exit
fi

# TimeStep Calculation
x=500000;
ns=$1;
ts=$((x * ns));

comstart=1
comend=$(tail -3 com.pdb | awk '{print $5}')

# Input file for Water Minimization

printf "Minimize all hydrogens
 &cntrl
  imin = 1,
  maxcyc = 5000,
  ncyc = 500,
  ntr = 1,
  cut = 10.0,
  saltcon=0.15,
  restraint_wt = 10.0,
  restraintmask = ':${comstart}-${comend} & !@H=',
/
" > watermin.in;


# Input file for Overall Minimization

printf "Unrestrained minimization, periodic system, xmin default
 &cntrl
  imin = 1,
  ntmin = 1,
  maxcyc = 5000,
  ncyc = 500,
  ntb = 1,cut=10.0,
  saltcon=0.15,
/
" > min.in;

# Input file for Temperature Equilibration

printf "heat (Restraints - protein and ligand)
 &cntrl
  imin=0,irest=0,ntx=1,
  nstlim=100000,dt=0.002,
  ntc=2,ntf=2,
  ntt=3, gamma_ln = 0.2, ig = -1,
  cut=10.0, ntb=1,ntr=1,
  ntpr=5000, ntwx=5000,
  ntwr=20000,
  saltcon=0.15,
  tempi=0.0, temp0=150.0,
  restraint_wt = 5.0,
  restraintmask = ':${comstart}-${comend}',
/
" > heat.in;


# Input file for second stage of Temperature Equilibration

printf "heat (Restraints - protein and ligand)
 &cntrl
  imin=0,irest=1,ntx=5,
  nstlim=100000,dt=0.002,
  ntc=2,ntf=2,
  ntt=3, gamma_ln = 0.2, ig = -1,
  cut=10.0, ntb=1,ntr=1,
  ntpr=5000, ntwx=5000,
  ntwr=20000,
  saltcon=0.15,
  tempi=150.0, temp0=300.0,
  restraint_wt = 5.0,
  restraintmask = ':${comstart}-${comend}',
/
" > heat1.in;


# Input file for Density Equilibration

printf "density (Restraints - protein and ligand)
 &cntrl
  imin=0,irest=1,ntx=5,
  ntc=2,ntf=2,
  cut=10.0, ntb=2, ntr=1, nscm=1000,
  ntpr=5000, ntwx=5000,
  temp0=300.0,ntr=1,ioutfm=1,ntxo=2,
  ntp = 1, pres0 = 1.0, taup =2.0,
  nstlim = 100000, dt = 0.002,
  saltcon=0.15,
  ntt=3, gamma_ln = 0.2, ig = -1,
  restraint_wt = 5.0,
  restraintmask = ':${comstart}-${comend}',
/
" > densi.in;


# Input for Overall system equilbration

printf "equilibration  (Restraints - protein and ligand)
 &cntrl
  imin=0,irest=1,ntx=5,
  nstlim=100000,dt=0.002,
  ntc=2,ntf=2,ioutfm=1,ntxo=2,
  ntr=1,ntt=3, gamma_ln = 0.2, ig = -1,
  cut=10.0, ntb=2, ntp=1, taup=2.0,
  ntpr=5000, ntwx=5000,nscm=1000
  saltcon=0.15,
  temp0=300.0, pres0 = 1.0,
  restraint_wt = 2.0,
  restraintmask = ':${comstart}-${comend}',
/
" > equil.in;


# Input for second stage of Overall system equilibration

printf "equilibration (Restraints - None)
 &cntrl
  imin=0,irest=1,ntx=5,
  nstlim=50000, dt=0.002,
  ntc=2,ntf=2,ioutfm=1,ntxo=2,
  ntr=0,ntt=3, gamma_ln = 0.2, ig = -1,
  cut=10.0, ntb=2, ntp=1, taup=2.0,
  ntpr=5000, ntwx=5000,nscm=1000
  saltcon=0.15,
  temp0=300.0, pres0 = 1.0,
/
" > equil1.in;

# Input for Production Run

printf "Production at constant volume and temperature, ${ns} ns
 &cntrl
  imin=0, irest=1, ntx=5,
  ntpr=1000, ntwx=1000, ntwr=10000,
  ntb=2, ntr=0,
  ntp=1, pres0 = 1.0, taup = 2.0,
  ntc=2, ntf=2,
  cut=10.0, nscm=1000,
  nstlim=${ts}, dt=0.002,
  saltcon=0.15,
  temp0=300.0,ntt=3, gamma_ln = 0.2, ig = -1,ioutfm=1,ntxo=2,
/
" > prod_${ns}.in;


echo "--------------------------------------------------";
echo "Complex Start: ${comstart} ";
echo "Complex End: ${comend} ";
echo "---------------INPUT FILES CREATED--------------- ";