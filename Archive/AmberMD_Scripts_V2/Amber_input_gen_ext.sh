#!/bin/bash
if [ ! -n "$1" ];then
	echo ""
	echo "This script will create input and sh file to extend Molecular Dynamics Simulation"
	echo "Use the following flags to run the script"
	echo "-i = Name of last trajectory without file extension"
	echo "-o = Name of new trajectory without file extension"
	echo "-n = Time period of simulation in nanoseconds (ns)"
	echo ""
	echo "Usage: $0 -i <input trajectory> -o <output trajectory> -n <MD time period>"
	echo ""
	echo "Example: $0 -i prod1 -o prod2 -n 20"
	echo "This will create input for extending the MD simulation for 20 ns "
	echo ""
	exit
fi

while getopts i:o:n: flag
do
	case "${flag}" in
		i) inptrj=${OPTARG};;
		o) outtrj=${OPTARG};;
		n) timeperiod=${OPTARG};;
	esac
done

if [ -f prod_ext.in ];then
	rm prod_ext.in;
fi

if [ -f Amber_fin_ext.sh ];then
	rm Amber_fin_ext.sh;
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

echo "Production at constant volume and temperature, $timeperiod ns" >> prod_ext.in;
echo " &cntrl" >> prod_ext.in;
echo "  imin=0, irest=1, ntx=5," >> prod_ext.in;
echo "  ntpr=1000, ntwx=1000, ntwr=10000," >> prod_ext.in;
echo "  ntb=2, ntr=0," >> prod_ext.in;
echo "  ntp=1, pres0 = 1.0, taup = 2.0," >> prod_ext.in;
echo "  ntc=2, ntf=2," >> prod_ext.in
echo "  cut=10.0, nscm=1000," >> prod_ext.in;
echo "  nstlim=$timestep, dt=0.002," >> prod_ext.in;
echo "  temp0=300.0,ntt=3, gamma_ln = 0.2, ig = -1,ioutfm=1,ntxo=2," >> prod_ext.in;
echo "/" >> prod_ext.in;
echo "END" >> prod_ext.in;
echo "END" >> prod_ext.in;

if [ -f "prod_ext.in" ];then
        echo "prod_ext.in - Done"
		echo ""
else
        echo "prod_ext.in - Not Done"
        echo ""
fi

# Script for extension of Production Run

echo "#!/bin/bash" >> Amber_fin_ext.sh;
echo "if [ ! -n \"\$1\" ];then" >> Amber_fin_ext.sh;
echo "  	echo \"\";" >> Amber_fin_ext.sh;
echo "  	echo \"------------------------------------------------\";" >> Amber_fin_ext.sh;
echo "  	echo \"This script will perform minimization and equilibration of the solvated system, followed by production run\";" >> Amber_fin_ext.sh;
echo "  	echo \"Example: \$0 0\";" >> Amber_fin_ext.sh;
echo "  	echo \"This will perform gpu based calculations at 0th gpu card\";" >> Amber_fin_ext.sh;
echo "  	echo \"------------------------------------------------\";" >> Amber_fin_ext.sh;
echo "  	echo \"\";" >> Amber_fin_ext.sh;
echo "  	exit" >> Amber_fin_ext.sh;
echo "fi" >> Amber_fin_ext.sh;
echo "" >> Amber_fin_ext.sh;

echo "" >> Amber_fin_ext.sh;

echo "echo \"\";" >> Amber_fin_ext.sh;
echo "echo \"**********************************************\";" >> Amber_fin_ext.sh;
echo "echo \"Selected CUDA device for the current MD = \$1\";" >> Amber_fin_ext.sh;
echo "echo \"**********************************************\";" >> Amber_fin_ext.sh;
echo "echo \"\";" >> Amber_fin_ext.sh;

echo "" >> Amber_fin_ext.sh;

echo "export CUDA_VISIBLE_DEVICES=\$1" >> Amber_fin_ext.sh;

echo "" >> Amber_fin_ext.sh;

echo "pmemd.cuda -O -i prod_ext.in -o $outtrj.out -p com-sol1.prmtop -c $inptrj.rst -r $outtrj.rst -x $outtrj.nc -ref $inptrj.rst" >> Amber_fin_ext.sh;

if [ -f "Amber_fin_ext.sh" ];then
        echo "Amber_fin_ext.sh - Done"
		echo ""
else
        echo "Amber_fin_ext.sh - Not Done"
        echo ""
fi

echo "***************************************************";