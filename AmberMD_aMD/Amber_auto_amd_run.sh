#!/bin/bash
if [ ! -n "$1" ];then
	echo ""
	echo "This script will run Minimization and 5ns Equilibration for aMD simulation"
	echo ""
	echo "Example: $0 0";
	echo "This will perform 5ns equilibration for aMD simulation at 0th gpu card";
	echo
	exit
fi

# TimeStep Calculation
x=500000;
y=5;
ts=$((x * y));

# Input generation for Minimization, Heating, Density, Equilibration and Production Run

lignum=$(awk '/UNK/ { print $5;exit; }' com.pdb);
recstart=1
recend=$((lignum - 1))

echo "";
echo "*****************___INPUTS___**********************";
echo "Protein Start: $recstart";
echo "Protein End: $recend";
echo "Ligand number: $lignum";
echo "Time period in nanoseconds (ns): $y";
echo "Calculated Time Step for $y ns = $ts";
echo "***************************************************";
echo "----------------INPUT FILES CREATED----------------";

# Input file for Water Minimization

if [ -f watermin.in ];then
        rm watermin.in
fi

printf "Minimize all hydrogens
 &cntrl
  imin = 1,
  maxcyc = 5000,
  ncyc = 500,
  ntr = 1,
  cut = 10.0,
  saltcon=0.15,
/
Keep protein and ligand fixed
10.0
RES $recstart $lignum
END
END
" >> watermin.in;

if [ -f "watermin.in" ];then
        echo "watermin.in - Done"
else
        echo "watermin.in - Not Done"
fi

# Input file for Overall Minimization

if [ -f min.in ];then
        rm min.in
fi

printf "Unrestrained minimization, periodic system, xmin default
 &cntrl
  imin = 1,
  ntmin = 1,
  maxcyc = 5000,
  ncyc = 500,
  ntb = 1,cut=10.0,
  saltcon=0.15,
/
END
END
" >> min.in;

if [ -f "min.in" ];then
        echo "min.in - Done"
else
        echo "min.in - Not Done"
fi


# Input file for Temperature Equilibration

if [ -f heat.in ];then
        rm heat.in
fi

printf "heat
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
/
Keep protein and ligand fixed
10.0
RES $recstart $lignum
END
END
" >> heat.in;

if [ -f "heat.in" ];then
        echo "heat.in - Done"
else
        echo "heat.in - Not Done"
fi

# Input file for second stage of Temperature Equilibration

if [ -f heat1.in ];then
        rm heat1.in
fi

printf "heat
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
/
Keep protein and ligand fixed
10.0
RES $recstart $lignum
END
END
" >> heat1.in;

if [ -f "heat1.in" ];then
        echo "heat1.in - Done"
else
        echo "heat1.in - Not Done"
fi

# Input file for Density Equilibration

if [ -f densi.in ];then
        rm densi.in
fi

printf "density
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
/
Keep protein and ligand fixed
10.0
RES $recstart $lignum
END
END
" >> densi.in;


if [ -f "densi.in" ];then
        echo "densi.in - Done"
else
        echo "densi.in - Not Done"
fi

# Input for Overall system equilbration

if [ -f equil.in ];then
        rm equil.in
fi

printf "equilibration
 &cntrl
  imin=0,irest=1,ntx=5,
  nstlim=100000,dt=0.002,
  ntc=2,ntf=2,ioutfm=1,ntxo=2,
  ntr=1,ntt=3, gamma_ln = 0.2, ig = -1,
  cut=10.0, ntb=2, ntp=1, taup=2.0,
  ntpr=5000, ntwx=5000,nscm=1000
  saltcon=0.15,
  temp0=300.0, pres0 = 1.0,
/
Keep protein and ligand fixed
10.0
RES $recstart $lignum
END
END
" >> equil.in;

if [ -f "equil.in" ];then
        echo "equil.in - Done"
else
        echo "equil.in - Not Done"
fi

# Input for 5ns Production Run

if [ -f prod_5ns.in ];then
        rm prod_5ns.in
fi

# ntwx is changed from 1000 to 5000 to reduce the no. of frames saved and overall trajectory file size
printf "Production at constant volume and temperature, 5 ns
 &cntrl
  imin=0, irest=1, ntx=5,
  ntpr=1000, ntwx=5000, ntwr=10000,
  ntb=2, ntr=0,
  ntp=1, pres0 = 1.0, taup = 2.0,
  ntc=2, ntf=2,
  cut=10.0, nscm=1000,
  nstlim=2500000, dt=0.002,
  saltcon=0.15,
  temp0=300.0,ntt=3, gamma_ln = 0.2, ig = -1,ioutfm=1,ntxo=2,
/
END
END
" >> prod_5ns.in;

if [ -f "prod_5ns.in" ];then
        echo "prod_5ns.in - Done"
else
        echo "prod_5ns.in - Not Done"
fi


# PMEMD run - Water Minimization, Heating and Density Equilibration

echo "***************************************************";
echo "Selected CUDA device for the current MD = $1";
echo "***************************************************";

export CUDA_VISIBLE_DEVICES=$1

pmemd.cuda -O -i watermin.in -o watermin.out -p com-sol1.prmtop -c com-sol1.inpcrd -r watermin.rst -ref com-sol1.inpcrd
pmemd.cuda -O -i min.in -o min.out -p com-sol1.prmtop -c watermin.rst -r min.rst -x min.mdcrd -ref watermin.rst
pmemd.cuda -O -i heat.in -o heat.out -p com-sol1.prmtop -c min.rst -r heat.rst -x heat.mdcrd -ref min.rst
pmemd.cuda -O -i heat1.in -o heat1.out -p com-sol1.prmtop -c heat.rst -r heat1.rst -x heat1.mdcrd -ref heat.rst
pmemd.cuda -O -i densi.in -o densi.out -p com-sol1.prmtop -c heat1.rst -r density.rst -x densi.nc -ref heat1.rst

if [ -f density.rst ];then
	pmemd.cuda -O -i equil.in -o equil.out -p com-sol1.prmtop -c density.rst -r equil.rst -x equil.nc -ref density.rst
	pmemd.cuda -O -i prod_5ns.in -o prod_5ns.out -p com-sol1.prmtop -c equil.rst -r prod_5ns.rst -x prod_5ns.nc -ref equil.rst
else
	sander -O -i densi.in -o densi.out -p com-sol1.prmtop -c heat1.rst -r density.rst -x densi.nc -ref heat1.rst
	pmemd.cuda -O -i equil.in -o equil.out -p com-sol1.prmtop -c density.rst -r equil.rst -x equil.nc -ref density.rst
	pmemd.cuda -O -i prod_5ns.in -o prod_5ns.out -p com-sol1.prmtop -c equil.rst -r prod_5ns.rst -x prod_5ns.nc -ref equil.rst
fi

