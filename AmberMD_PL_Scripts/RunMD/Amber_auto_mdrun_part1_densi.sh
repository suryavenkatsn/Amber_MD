#!/bin/bash
if [ ! -n "$1" ];then
	echo ""
	echo "This script will run Minimization, Equilibration and Production MD for the modelled sytem"
	echo ""
	echo "Example: $0 20 0";
	echo "This will perform 20 ns MD simulation at 0th gpu card";
	echo
	exit
fi

# TimeStep Calculation
x=500000;
y=$1;
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
echo "Time period in nanoseconds (ns): $1";
echo "Calculated Time Step for $1 ns = $ts";
echo "***************************************************";
echo "----------------INPUT FILES CREATED----------------";

# Input file for Water Minimization

if [ -f watermin.in ];then
        rm watermin.in
fi

echo "Minimize all hydrogens" >> watermin.in;
echo " &cntrl" >> watermin.in;
echo "  imin = 1," >> watermin.in;
echo "  maxcyc = 5000," >> watermin.in;
echo "  ncyc = 500," >> watermin.in;
echo "  ntr = 1," >> watermin.in;
echo "  cut = 10.0," >> watermin.in;
echo "  saltcon=0.15," >> watermin.in;
echo "/" >> watermin.in;
echo "Keep protein and ligand fixed" >> watermin.in;
echo "10.0" >> watermin.in;
echo "RES $recstart $lignum" >> watermin.in;
echo "END" >> watermin.in;
echo "END" >> watermin.in;

if [ -f "watermin.in" ];then
        echo "watermin.in - Done"
else
        echo "watermin.in - Not Done"
fi

# Input file for Overall Minimization

if [ -f min.in ];then
        rm min.in
fi

echo "Unrestrained minimization, periodic system, xmin default" >> min.in;
echo " &cntrl" >> min.in;
echo "  imin = 1," >> min.in;
echo "  ntmin = 1," >> min.in;
echo "  maxcyc = 5000," >> min.in;
echo "  ncyc = 500," >> min.in;
echo "  ntb = 1,cut=10.0," >> min.in;
echo "  saltcon=0.15," >> min.in;
echo "/" >> min.in;
echo "END" >> min.in;
echo "END" >> min.in;

if [ -f "min.in" ];then
        echo "min.in - Done"
else
        echo "min.in - Not Done"
fi


# Input file for Temperature Equilibration

if [ -f heat.in ];then
        rm heat.in
fi

echo "heat" >> heat.in;
echo " &cntrl" >> heat.in;
echo "  imin=0,irest=0,ntx=1," >> heat.in;
echo "  nstlim=100000,dt=0.002," >> heat.in;
echo "  ntc=2,ntf=2," >> heat.in;
echo "  ntt=3, gamma_ln = 0.2, ig = -1," >> heat.in;
echo "  cut=10.0, ntb=1,ntr=1," >> heat.in;
echo "  ntpr=5000, ntwx=5000," >> heat.in;
echo "  ntwr=20000," >> heat.in;
echo "  saltcon=0.15," >> heat.in;
echo "  tempi=0.0, temp0=150.0," >> heat.in;
echo "/" >> heat.in;
echo "Keep protein and ligand fixed" >> heat.in;
echo "5.0" >> heat.in;
echo "RES $recstart $lignum" >> heat.in;
echo "END" >> heat.in;
echo "END" >> heat.in;

if [ -f "heat.in" ];then
        echo "heat.in - Done"
else
        echo "heat.in - Not Done"
fi

# Input file for second stage of Temperature Equilibration

if [ -f heat1.in ];then
        rm heat1.in
fi

echo "heat" >> heat1.in;
echo " &cntrl" >> heat1.in;
echo "  imin=0,irest=1,ntx=5," >> heat1.in;
echo "  nstlim=100000,dt=0.002," >> heat1.in;
echo "  ntc=2,ntf=2," >> heat1.in;
echo "  ntt=3, gamma_ln = 0.2, ig = -1," >> heat1.in;
echo "  cut=10.0, ntb=1,ntr=1," >> heat1.in;
echo "  ntpr=5000, ntwx=5000," >> heat1.in;
echo "  ntwr=20000," >> heat1.in;
echo "  saltcon=0.15," >> heat1.in;
echo "  tempi=150.0, temp0=300.0," >> heat1.in;
echo "/" >> heat1.in;
echo "Keep protein and ligand fixed" >> heat1.in;
echo "5.0" >> heat1.in;
echo "RES $recstart $lignum" >> heat1.in;
echo "END" >> heat1.in;
echo "END" >> heat1.in;

if [ -f "heat1.in" ];then
        echo "heat1.in - Done"
else
        echo "heat1.in - Not Done"
fi

# Input file for Density Equilibration

if [ -f densi.in ];then
        rm densi.in
fi

echo "density" >> densi.in;
echo " &cntrl" >> densi.in;
echo "  imin=0,irest=1,ntx=5," >> densi.in;
echo "  ntc=2,ntf=2," >> densi.in;
echo "  cut=10.0, ntb=2, ntr=1, nscm=1000," >> densi.in;
echo "  ntpr=5000, ntwx=5000," >> densi.in;
echo "  temp0=300.0,ntr=1,ioutfm=1,ntxo=2," >> densi.in;
echo "  ntp = 1, pres0 = 1.0, taup =2.0," >> densi.in;
echo "  nstlim = 100000, dt = 0.002," >> densi.in;
echo "  saltcon=0.15," >> densi.in;
echo "  ntt=3, gamma_ln = 0.2, ig = -1," >> densi.in;
echo "/" >> densi.in;
echo "Keep protein and ligand fixed" >> densi.in;
echo "5.0" >> densi.in;
echo "RES $recstart $lignum" >> densi.in;
echo "END" >> densi.in;
echo "END" >> densi.in;


if [ -f "densi.in" ];then
        echo "densi.in - Done"
else
        echo "densi.in - Not Done"
fi

# Input for Overall system equilbration

if [ -f equil.in ];then
        rm equil.in
fi

echo "equilibration" >> equil.in;
echo " &cntrl" >> equil.in;
echo "  imin=0,irest=1,ntx=5," >> equil.in;
echo "  nstlim=100000,dt=0.002," >> equil.in;
echo "  ntc=2,ntf=2,ioutfm=1,ntxo=2," >> equil.in;
echo "  ntr=1,ntt=3, gamma_ln = 0.2, ig = -1," >> equil.in;
echo "  cut=10.0, ntb=2, ntp=1, taup=2.0," >> equil.in;
echo "  ntpr=5000, ntwx=5000,nscm=1000" >> equil.in;
echo "  saltcon=0.15," >> equil.in;
echo "  temp0=300.0, pres0 = 1.0," >> equil.in;
echo "/" >> equil.in;
echo "Keep protein and ligand fixed" >> equil.in;
echo "2.0" >> equil.in;
echo "RES $recstart $lignum" >> equil.in;
echo "END" >> equil.in;
echo "END" >> equil.in;

if [ -f "equil.in" ];then
        echo "equil.in - Done"
else
        echo "equil.in - Not Done"
fi

# Input for second stage of Overall system equilibration

if [ -f equil1.in ];then
        rm equil1.in
fi

echo "equilibration" >> equil1.in;
echo " &cntrl" >> equil1.in;
echo "  imin=0,irest=1,ntx=5," >> equil1.in;
echo "  nstlim=50000, dt=0.002," >> equil1.in;
echo "  ntc=2,ntf=2,ioutfm=1,ntxo=2," >> equil1.in;
echo "  ntr=0,ntt=3, gamma_ln = 0.2, ig = -1," >> equil1.in;
echo "  cut=10.0, ntb=2, ntp=1, taup=2.0," >> equil1.in;
echo "  ntpr=5000, ntwx=5000,nscm=1000" >> equil1.in;
echo "  saltcon=0.15," >> equil1.in;
echo "  temp0=300.0, pres0 = 1.0," >> equil1.in;
echo "/" >> equil1.in;
echo "END" >> equil1.in;
echo "END" >> equil1.in;

if [ -f "equil1.in" ];then
        echo "equil1.in - Done"
else
        echo "equil1.in - NotDone"
fi

# Input for Production Run

if [ -f prod.in ];then
        rm prod.in
fi

echo "Production at constant volume and temperature, $1 ns" >> prod.in;
echo " &cntrl" >> prod.in;
echo "  imin=0, irest=1, ntx=5," >> prod.in;
echo "  ntpr=1000, ntwx=1000, ntwr=10000," >> prod.in;
echo "  ntb=2, ntr=0," >> prod.in;
echo "  ntp=1, pres0 = 1.0, taup = 2.0," >> prod.in;
echo "  ntc=2, ntf=2," >> prod.in;
echo "  cut=10.0, nscm=1000," >> prod.in;
echo "  nstlim=$ts, dt=0.002," >> prod.in;
echo "  saltcon=0.15," >> prod.in;
echo "  temp0=300.0,ntt=3, gamma_ln = 0.2, ig = -1,ioutfm=1,ntxo=2," >> prod.in;
echo "/" >> prod.in;
echo "END" >> prod.in;
echo "END" >> prod.in;

if [ -f "prod.in" ];then
        echo "prod.in - Done"
else
        echo "prod.in - Not Done"
fi


# Water Minimization, Heating and Density Equilibration

echo "***************************************************";
echo "Selected CUDA device for the current MD = $2";
echo "***************************************************";

export CUDA_VISIBLE_DEVICES=$2

pmemd.cuda -O -i watermin.in -o watermin.out -p com-sol1.prmtop -c com-sol1.inpcrd -r watermin.rst -ref com-sol1.inpcrd
pmemd.cuda -O -i min.in -o min.out -p com-sol1.prmtop -c watermin.rst -r min.rst -x min.mdcrd -ref watermin.rst
pmemd.cuda -O -i heat.in -o heat.out -p com-sol1.prmtop -c min.rst -r heat.rst -x heat.mdcrd -ref min.rst
pmemd.cuda -O -i heat1.in -o heat1.out -p com-sol1.prmtop -c heat.rst -r heat1.rst -x heat1.mdcrd -ref heat.rst
pmemd.cuda -O -i densi.in -o densi.out -p com-sol1.prmtop -c heat1.rst -r density.rst -x densi.nc -ref heat1.rst

if [ -f density.rst ];then
	pmemd.cuda -O -i equil.in -o equil.out -p com-sol1.prmtop -c density.rst -r equil.rst -x equil.nc -ref density.rst
	pmemd.cuda -O -i equil1.in -o equil1.out -p com-sol1.prmtop -c equil.rst -r equil1.rst -x equil1.nc -ref equil.rst
	pmemd.cuda -O -i prod.in -o prod1.out -p com-sol1.prmtop -c equil1.rst -r prod1.rst -x prod1.nc -ref equil1.rst
else
	sander -O -i densi.in -o densi.out -p com-sol1.prmtop -c heat1.rst -r density.rst -x densi.nc -ref heat1.rst
	# pmemd.cuda -O -i equil.in -o equil.out -p com-sol1.prmtop -c density.rst -r equil.rst -x equil.nc -ref density.rst
	# pmemd.cuda -O -i equil1.in -o equil1.out -p com-sol1.prmtop -c equil.rst -r equil1.rst -x equil1.nc -ref equil.rst
	# pmemd.cuda -O -i prod.in -o prod1.out -p com-sol1.prmtop -c equil1.rst -r prod1.rst -x prod1.nc -ref equil1.rst
fi