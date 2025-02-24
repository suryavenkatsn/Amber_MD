#!/bin/bash
if [ ! -n "$1" ];then
	echo ""
	echo "Usage: $0 -i <input trajectory> -o <output trajectory> -n <MD time period> -g <0-3>"
	echo ""
	echo "Example: $0 -i prod1 -o prod2 -n 20 -g 0"
	echo "This will create input files and run extending MD simulation for 20 ns and concat trajectories"
	echo ""
	exit
fi

while getopts i:o:n:g: flag
do
	case "${flag}" in
		i) inptrj=${OPTARG};;
		o) outtrj=${OPTARG};;
		n) timeperiod=${OPTARG};;
		g) gpu=${OPTARG};;
	esac
done

if [ -f $outtrj.in ];then
	rm $outtrj.in;
fi


x=500000;
y=$timeperiod;
timestep=$((x * y));

echo "";
echo "*****************___INPUTS___**********************";
echo "Name of last trajectory: $inptrj";
echo "Name of extended trajectory: $outtrj";
echo "Time period in nanoseconds (ns): $timeperiod";
echo "Calculated Time Step for $timeperiod ns = $timestep";
echo "***************************************************";
echo "";
echo "*************___INPUT FILES CREATED___*************";



# Input for Extension of Production Run

echo "Production at constant volume and temperature, $timeperiod ns" >> $outtrj.in;
echo " &cntrl" >> $outtrj.in;
echo "  imin=0, irest=1, ntx=5," >> $outtrj.in;
echo "  ntpr=1000, ntwx=1000, ntwr=10000," >> $outtrj.in;
echo "  ntb=2, ntr=0," >> $outtrj.in;
echo "  ntp=1, pres0 = 1.0, taup = 2.0," >> $outtrj.in;
echo "  ntc=2, ntf=2," >> $outtrj.in
echo "  cut=10.0, nscm=1000," >> $outtrj.in;
echo "  nstlim=$timestep, dt=0.002," >> $outtrj.in;
echo "  saltcon=0.15," >> $outtrj.in;
echo "  temp0=300.0,ntt=3, gamma_ln = 0.2, ig = -1,ioutfm=1,ntxo=2," >> $outtrj.in;
echo "/" >> $outtrj.in;
echo "END" >> $outtrj.in;
echo "END" >> $outtrj.in;

if [ -f "$outtrj.in" ];then
        echo "$outtrj.in - Done"
		echo ""
else
        echo "$outtrj.in - Not Done"
        exit
fi

echo "***************************************************";
echo "Selected CUDA device for the current MD = $gpu";
echo "***************************************************";

export CUDA_VISIBLE_DEVICES=$gpu

pmemd.cuda -O -i $outtrj.in -o $outtrj.out -p com-sol1.prmtop -c $inptrj.rst -r $outtrj.rst -x $outtrj.nc -ref $inptrj.rst

# Trajectory Concatenation

if [ -f concat.in ];then
	rm concat.in;
fi

if [ -f concat.out ];then
	rm concat.out;
fi

ts1=$(awk '/nstlim/ { print $1 }' $inptrj.out | awk -F '[=,]' '{ print $2 }');
t1=$((ts1 / 1000));

ts2=$(awk '/nstlim/ { print $1 }' $outtrj.out | awk -F '[=,]' '{ print $2 }');
t2=$((ts2 / 1000));



echo "trajin $inptrj.nc 0 $t1 1" >> concat.in;
echo "trajin $outtrj.nc 0 $t2 1" >> concat.in;
echo "reference com-sol1.inpcrd" >> concat.in;
echo "trajout prod-all.nc" >> concat.in;

cpptraj -p com-sol1.prmtop -i concat.in > concat.out;

echo "**************************************************";
echo "Trajectory concatination is done successfully!";
echo "**************************************************";

