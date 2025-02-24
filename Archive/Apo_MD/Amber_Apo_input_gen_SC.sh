#!/bin/bash
if [ ! -n "$1" ];then
	echo ""
	echo "This script will create input and sh file to perform Molecular Dynamics Simulation"
	echo "Use the following flags to run the script"
	echo "-R = Starting residue no. of Receptor"
	echo "-r = Ending residue no. of Receptor"
	echo "-n = Time period of simulation in nanoseconds (ns)"
	echo ""
	echo "Usage: $0 -R <Rec Start> -r <Rec End> -n <MD time period>"
	echo ""
	echo "Example: $0 -R 1 -r 569 -n 20"
	echo "This will create input for running MD simulation for 20 ns "
	echo ""
	exit
fi

while getopts R:r:L:l:n: flag
do
	case "${flag}" in
		R) recstart=${OPTARG};;
		r) recend=${OPTARG};;
		n) timeperiod=${OPTARG};;
	esac
done


rm prtmin.in;
rm watermin.in;
rm min.in;
rm heat.in;
rm heat1.in;
rm densi.in;
rm equil.in;
rm equil1.in;
rm prod.in;


x=500000;
y=$timeperiod;
timestep=$((x * y));

echo "";
echo "*****************___INPUTS___**********************";
echo "Protein Start: $recstart";
echo "Protein End: $recend";
echo "Time period in nanoseconds (ns): $timeperiod";
echo "Calculated Time Step for $timeperiod ns = $timestep";
echo "***************************************************";
echo "";
echo "*************___INPUT FILES CREATED___*************";



# Input file for Complex Minimization

echo "Minimize water positions (and all hydrogens)" >> prtmin.in;
echo " &cntrl" >> prtmin.in;
echo "  imin = 1," >> prtmin.in;
echo "  maxcyc = 1000," >> prtmin.in;
echo "  ncyc = 500," >> prtmin.in
echo "  ntr = 1," >> prtmin.in
echo "  ntb = 0,cut=16.0," >> prtmin.in
echo "/" >> prtmin.in;
echo "END" >> prtmin.in;

if [ -f "prtmin.in" ];then
        echo "prtmin.in - Done"
else
        echo "prtmin.in - Not Done"
fi

# Input file for Water Minimization

echo "Minimize all hydrogens" >> watermin.in;
echo " &cntrl" >> watermin.in;
echo "  imin = 1," >> watermin.in;
echo "  maxcyc = 5000," >> watermin.in;
echo "  ncyc = 500," >> watermin.in;
echo "  ntr = 1," >> watermin.in;
echo "  cut = 10.0," >> watermin.in;
echo "  saltcon=0.15," >> watermin.in;
echo "/" >> watermin.in;
echo "Keep protein fixed" >> watermin.in;
echo "10.0" >> watermin.in;
echo "RES $recstart $recend" >> watermin.in;
echo "END" >> watermin.in;
echo "END" >> watermin.in;

if [ -f "watermin.in" ];then
        echo "watermin.in - Done"
else
        echo "watermin.in - Not Done"
fi

# Input file for Overall Minimization

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
echo "Keep protein fixed" >> heat.in;
echo "5.0" >> heat.in;
echo "RES $recstart $recend" >> heat.in;
echo "END" >> heat.in;
echo "END" >> heat.in;

if [ -f "heat.in" ];then
        echo "heat.in - Done"
else
        echo "heat.in - Not Done"
fi

# Input file for second stage of Temperature Equilibration


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
echo "Keep protein fixed" >> heat1.in;
echo "5.0" >> heat1.in;
echo "RES $recstart $recend" >> heat1.in;
echo "END" >> heat1.in;
echo "END" >> heat1.in;

if [ -f "heat1.in" ];then
        echo "heat1.in - Done"
else
        echo "heat1.in - Not Done"
fi

# Input file for Density Equilibration

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
echo "Keep protein fixed" >> densi.in;
echo "5.0" >> densi.in;
echo "RES $recstart $recend" >> densi.in;
echo "END" >> densi.in;
echo "END" >> densi.in;


if [ -f "densi.in" ];then
        echo "densi.in - Done"
else
        echo "densi.in - Not Done"
fi

# Input for Overall system equilbration

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
echo "Keep protein fixed" >> equil.in;
echo "2.0" >> equil.in;
echo "RES $recstart $recend" >> equil.in;
echo "END" >> equil.in;
echo "END" >> equil.in;

if [ -f "equil.in" ];then
        echo "equil.in - Done"
else
        echo "equil.in - Not Done"
fi

# Input for second stage of Overall system equilibration

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

echo "Production at constant volume and temperature, $timeperiod ns" >> prod.in;
echo " &cntrl" >> prod.in;
echo "  imin=0, irest=1, ntx=5," >> prod.in;
echo "  ntpr=1000, ntwx=1000, ntwr=10000," >> prod.in;
echo "  ntb=2, ntr=0," >> prod.in;
echo "  ntp=1, pres0 = 1.0, taup = 2.0," >> prod.in;
echo "  ntc=2, ntf=2," >> prod.in;
echo "  cut=10.0, nscm=1000," >> prod.in;
echo "  nstlim=$timestep, dt=0.002," >> prod.in;
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

echo "***************************************************";
