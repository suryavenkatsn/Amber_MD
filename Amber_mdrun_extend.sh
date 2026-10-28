#!/bin/bash
if [ ! -n "$1" ];then
	echo ""
	echo "Usage: $0 -i <input trajectory> -o <output trajectory> -n <MD time period> -g <0-3>"
	echo "Example: $0 -i prod1 -o prod2 -n 20 -g 0"
	echo ""
	exit
fi

while getopts i:o:n:g: flag
do
	case "${flag}" in
		i) inptrj=${OPTARG};;
		o) outtrj=${OPTARG};;
		n) ns=${OPTARG};;
		g) gpu=${OPTARG};;
	esac
done

# TimeStep Calculation
x=500000;
ts=$((x * ns));

# Input for Production Run extension

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
" > prod_ext_${ns}.in;

export CUDA_VISIBLE_DEVICES=${gpu}

pmemd.cuda -O -i prod_ext_${ns}.in -o prod_ext_${ns}.out -p com-sol1.prmtop -c ${inptrj}.rst -r ${outtrj}.rst -x ${outtrj}.nc -ref ${inptrj}.rst