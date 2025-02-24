#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will create input and sh file to perform Molecular Dynamics Simulation"
    echo "Use the following flags to run the script"
	echo "-R = Starting residue no. of Receptor"
	echo "-r = Ending residue no. of Receptor"
	echo "-L = Starting residue no. of Ligand"
	echo "-l = Ending residue no. of Ligand"
	echo "-n = Time period of simulation in nanoseconds (ns)"
    echo
    echo "Usage: $0 -R <Start of Receptor> -r <End of Receptor> -L <Start of Ligand> -l <End of Ligand> -n <MD time period>"
    echo ""
    echo "Example: $0 -R 1 -r 569 -L 570 -l 570 -n 20"
    echo "This will create input for running 20 ns simulation"
    echo 
    exit
fi

while getopts R:r:L:l:n: flag
do
	case "${flag}" in
		R) recstart=${OPTARG};;
		r) recend=${OPTARG};;
		L) ligstart=${OPTARG};;
		l) ligend=${OPTARG};;
		n) timeperiod=${OPTARG};;
	esac
done


echo "Protein Start: $recstart";
echo "Protein End: $recend";
echo "Ligand Start: $ligstart";
echo "Ligand End: $ligend";
echo "Time period in nanoseconds (ns): $timeperiod";
echo "**************************************************";
echo "";

# Remove exisiting files to avoid duplication
rm drug.in;
rm complexmin.in;
rm int.sh;
rm watermin.in;
rm min.in;
rm heat.in;
rm heat1.in
rm densi.in;
rm equil.in;
rm equil1.in;
rm prod.in;
rm fin.sh;
rm sander_densi.sh;
rm fin_2.sh;


# Input file for Ligand Minimization

echo "Minimize drug coords (drug is resid $ligstart) and xtal water" >> drug.in;
echo "  imin   = 1," >> drug.in;
echo "  maxcyc = 1000," >> drug.in;
echo "  ncyc = 500," >> drug.in;
echo "  ntr	= 1," >> drug.in;
echo "  ntb    = 0," >> drug.in;
echo "  cut   = 16.0," >> drug.in;
echo "/" >> drug.in;
echo "Keep protein fixed" >> drug.in;
echo "10.0" >> drug.in;
echo "RES $recstart $recend" >> drug.in;
echo "END" >> drug.in;
echo "END" >> drug.in;

echo "drug.in created successfully!";

# Input file for Complex Minimization

echo "Minimize water positions (and all hydrogens)" >> complexmin.in;
echo " &cntrl" >> complexmin.in;
echo "  imin   = 1," >> complexmin.in;
echo "  maxcyc = 1000," >> complexmin.in;
echo "  ncyc = 500," >> complexmin.in;
echo "  ntr = 1," >> complexmin.in;
echo "  ntb = 0,cut=16.0," >> complexmin.in;
echo "/" >> complexmin.in;
echo "END" >> complexmin.in;

echo "complex.in created successfully!";

# Sh script for Ligand and Complex Minimization

echo "sander -O -i drug.in -o drug.out -p com.prmtop -c com.inpcrd -r drug.rst -x drug.mdcrd -ref com.inpcrd" >> int.sh;
echo "sander -O -i complexmin.in -o complexmin.out -p com.prmtop -c drug.rst -r complexmin.rst -x complexmin.mdcrd -ref drug.rst" >> int.sh;

echo "int.sh created successfully!";

# Input for Water Minimzation

echo "Minimize all hydrogens" >> watermin.in;
echo " &cntrl" >> watermin.in;
echo "  imin   = 1," >> watermin.in;
echo "  maxcyc = 5000," >> watermin.in;
echo "  ncyc = 500," >> watermin.in;
echo "  ntr    = 1," >> watermin.in;
echo "  ntb    = 1," >> watermin.in;
echo "  cut   = 10.0," >> watermin.in;
echo "/" >> watermin.in;
echo "Keep protein and ligand fixed" >> watermin.in;
echo "10.0" >> watermin.in;
echo "RES $recstart $ligend" >> watermin.in;
echo "END" >> watermin.in;
echo "END" >> watermin.in;

echo "watermin.in created successfully!";

# Input for Overall Minimization

echo "Unrestrained mimization, periodic system, xmin default" >> min.in;
echo " &cntrl" >> min.in;
echo "  imin   = 1," >> min.in;
echo "  ntmin = 1," >> min.in;
echo "  maxcyc = 5000," >> min.in;
echo "  ncyc = 500," >> min.in;
echo "  ntb = 1,cut=10.0," >> min.in;
echo "/" >> min.in;
echo "END" >> min.in;
echo "END" >> min.in;

echo "min.in created successfully!";

# Input for Temperature Equilibration

echo "heat" >> heat.in;
echo " &cntrl" >> heat.in;
echo "  imin=0,irest=0,ntx=1," >> heat.in;
echo "  nstlim=100000,dt=0.002," >> heat.in;
echo "  ntc=2,ntf=2," >> heat.in;
echo "  ntt=3, gamma_ln = 0.2, ig = -1," >> heat.in;
echo "  cut=10.0, ntb=1,ntr=1," >> heat.in;
echo "  ntpr=5000, ntwx=5000," >> heat.in;
echo "  ntwr=20000," >> heat.in;
echo "   tempi=0.0, temp0=150.0," >> heat.in;
echo "/" >> heat.in;
echo "Keep protein and ligand fixed" >> heat.in;
echo "5.0" >> heat.in;
echo "RES $recstart $ligend" >> heat.in;
echo "END" >> heat.in;
echo "END" >> heat.in;

echo "heat.in created successfully!";

# Input for second stage of Temperature Equilibration

echo "heat" >> heat1.in;
echo " &cntrl" >> heat1.in;
echo "  imin=0,irest=1,ntx=5," >> heat1.in;
echo "  nstlim=100000,dt=0.002," >> heat1.in;
echo "  ntc=2,ntf=2," >> heat1.in;
echo " ntt=3, gamma_ln = 0.2, ig = -1," >> heat1.in;
echo "  cut=10.0, ntb=1,ntr=1," >> heat1.in;
echo "  ntpr=5000, ntwx=5000," >> heat1.in;
echo "  ntwr=20000," >> heat1.in;
echo "   tempi=150.0, temp0=300.0," >> heat1.in;
echo "/" >> heat1.in;
echo "Keep protein and ligand fixed" >> heat1.in;
echo "5.0" >> heat1.in;
echo "RES $recstart $ligend" >> heat1.in;
echo "END" >> heat1.in;
echo "END" >> heat1.in;

echo "heat1.in created successfully!";

# Input for Density Equilibration

echo "density" >> densi.in;
echo " &cntrl" >> densi.in;
echo "  imin=0,irest=1,ntx=5," >> densi.in;
echo "  ntc=2,ntf=2," >> densi.in;
echo "  cut=10.0, ntb=2, ntr=1, nscm=1000," >> densi.in;
echo "  ntpr=5000, ntwx=5000," >> densi.in;
echo "  temp0=300.0,ntr=1,ioutfm=1,ntxo=2," >> densi.in;
echo "  ntp = 1, pres0 = 1.0, taup = 2.0," >> densi.in;
echo "  nstlim = 100000, dt = 0.002," >> densi.in;
echo "  ntt=3, gamma_ln = 0.2, ig = -1," >> densi.in;
echo "/" >> densi.in;
echo "Keep protein and ligand fixed" >> densi.in;
echo "5.0" >> densi.in;
echo "RES $recstart $ligend" >> densi.in;
echo "END" >> densi.in;
echo "END" >> densi.in;

echo "densi.in created successfully!"

# Input for Overall system equilibration

echo "equilibration" >> equil.in;
echo " &cntrl" >> equil.in;
echo "  imin=0,irest=1,ntx=5," >> equil.in;
echo "  nstlim=100000,dt=0.002," >> equil.in;
echo "  ntc=2,ntf=2,ioutfm=1,ntxo=2," >> equil.in;
echo "  ntr=1,ntt=3, gamma_ln = 0.2, ig = -1," >> equil.in;
echo "  cut=10.0, ntb=2, ntp=1, taup=2.0," >> equil.in;
echo "  ntpr=5000, ntwx=5000,nscm=1000," >> equil.in;
echo "  temp0=300.0, pres0 = 1.0," >> equil.in;
echo "/" >> equil.in;
echo "Keep protein and ligand fixed" >> equil.in;
echo "2.0" >> equil.in;
echo "RES $recstart $ligend" >> equil.in;
echo "END" >> equil.in;
echo "END" >> equil.in;

echo "equil.in created successfully!"

# Input for second stage of Overall system equilibration

echo "equilibration" >> equil1.in;
echo " &cntrl" >> equil1.in;
echo "  imin=0,irest=1,ntx=5," >> equil1.in;
echo "  nstlim=50000,dt=0.002," >> equil1.in;
echo "  ntc=2,ntf=2,ioutfm=1,ntxo=2," >> equil1.in;
echo "  ntr=0,ntt=3, gamma_ln = 0.2, ig = -1," >> equil1.in;
echo "  cut=10.0, ntb=2, ntp=1, taup=2.0," >> equil1.in;
echo "  ntpr=5000, ntwx=5000,nscm=1000," >> equil1.in;
echo "  temp0=300.0, pres0 = 1.0," >> equil1.in;
echo "/" >> equil1.in;
echo "END" >> equil1.in;
echo "END" >> equil1.in;

echo "equil1.in created successfully!";

# Input for Production Run
x=500000;
y=$timeperiod
timestep=$((x * y));
echo "---------------------------------------------------";
echo "Calculated Time Step for $timeperiod ns = $timestep";
echo "---------------------------------------------------";

echo "Production at constant volume and temperature, $timeperiod ns." >> prod.in;
echo " &cntrl" >> prod.in;
echo "  imin=0, irest=1, ntx=5," >> prod.in;
echo "   ntpr=1000, ntwx=1000, ntwr=10000," >> prod.in;
echo "  ntb=2, ntr=0," >> prod.in;
echo "  ntp=1, pres0 = 1.0, taup = 2.0," >> prod.in;
echo "  ntc=2, ntf=2," >> prod.in;
echo "  cut=10.0, nscm=1000," >> prod.in;
echo "   nstlim=$timestep, dt=0.002," >> prod.in;
echo "  temp0=300.0,ntt=3, gamma_ln = 0.2, ig = -1,ioutfm=1,ntxo=2," >> prod.in;
echo "/" >> prod.in;
echo "END" >> prod.in;
echo "END" >> prod.in;

echo "prod.in created successfully!";

# Script for Final run comprising all minimization, equilibration and production run
echo "#!/bin/bash" >> fin.sh;
echo "if [ ! -n \"\$1\" ];then" >> fin.sh;
echo "    echo """ >> fin.sh;
echo "    echo ---------------------------------------------------------" >> fin.sh;
echo "    echo "This script will perform minimization and equilibration of the solvated system, followed by production run"" >> fin.sh;
echo "    echo "Example: \$0 0"" >> fin.sh;
echo "    echo "This will perform gpu based calculations at 0th gpu card"" >> fin.sh;
echo "    echo ---------------------------------------------------------" >> fin.sh;
echo "    echo """ >> fin.sh;
echo "    exit" >> fin.sh;
echo "fi" >> fin.sh;
echo "echo "******************************************************";" >> fin.sh;
echo "echo "Selected CUDA_VISIBLE_DEVICES for the current MD = \$1";" >> fin.sh;
echo "echo "******************************************************";" >> fin.sh;

echo "" >> fin.sh;

echo "export CUDA_VISIBLE_DEVICES=\$1" >> fin.sh;
echo "" >> fin.sh;

echo "pmemd.cuda -O -i watermin.in -o watermin.out -p com-sol1.prmtop -c com-sol1.inpcrd -r watermin.rst -ref com-sol1.inpcrd" >> fin.sh;
echo "pmemd.cuda  -O -i min.in -o min.out -p com-sol1.prmtop -c watermin.rst -r min.rst -x min.mdcrd -ref watermin.rst" >> fin.sh;
echo "pmemd.cuda -O -i heat.in -o heat.out -p com-sol1.prmtop -c min.rst -r heat.rst -x heat.mdcrd -ref min.rst" >> fin.sh;
echo "pmemd.cuda -O -i heat1.in -o heat1.out -p com-sol1.prmtop -c heat.rst -r heat1.rst -x heat1.mdcrd -ref heat.rst" >> fin.sh;
echo "pmemd.cuda -O -i densi.in -o densi.out -p com-sol1.prmtop -c heat1.rst -r density.rst -x densi.nc -ref heat1.rst" >> fin.sh;
echo "pmemd.cuda -O -i equil.in -o equil.out -p com-sol1.prmtop -c density.rst -r equil.rst -x equil.nc -ref density.rst" >> fin.sh;
echo "pmemd.cuda -O -i equil1.in -o equil1.out -p com-sol1.prmtop -c equil.rst -r equil1.rst -x equil1.nc -ref equil.rst" >> fin.sh;
echo "pmemd.cuda -O -i prod.in -o prod1.out -p com-sol1.prmtop -c equil1.rst -r prod1.rst -x prod1.nc -ref equil1.rst" >> fin.sh;

echo "fin.sh created successfully!";

# Script for Sander Density Equilibration (Used when GPU based density equilbration failed)
echo "sander -O -i densi.in -o densi.out -p com-sol1.prmtop -c heat1.rst -r density.rst -x densi.nc -ref heat1.rst" >> sander_densi.sh;

echo "sander_densi.sh created successfully!";

# Script for remaining Equilibration and production run (Used when GPU based density equilbration failed)
echo "#!/bin/bash" >> fin_2.sh;
echo "if [ ! -n \"\$1\" ];then" >> fin_2.sh;
echo "    echo """ >> fin_2.sh;
echo "    echo ---------------------------------------------------------" >> fin_2.sh;
echo "    echo "This script will perform equilibration of the solvated system, followed by production run"" >> fin_2.sh;
echo "    echo "Example: \$0 0"" >> fin_2.sh;
echo "    echo "This will perform gpu based calculations at 0th gpu card"" >> fin_2.sh;
echo "    echo ---------------------------------------------------------" >> fin_2.sh;
echo "    echo """ >> fin_2.sh;
echo "    exit" >> fin_2.sh;
echo "fi" >> fin_2.sh;
echo "echo "******************************************************";" >> fin_2.sh;
echo "echo "Selected CUDA_VISIBLE_DEVICES for the current MD = \$1";" >> fin_2.sh;
echo "echo "******************************************************";" >> fin_2.sh;

echo "" >> fin_2.sh

echo "export CUDA_VISIBLE_DEVICES=\$1" >> fin_2.sh;
echo "" >> fin_2.sh

echo "pmemd.cuda -O -i equil.in -o equil.out -p com-sol1.prmtop -c density.rst -r equil.rst -x equil.nc -ref density.rst" >> fin_2.sh;
echo "pmemd.cuda -O -i equil1.in -o equil1.out -p com-sol1.prmtop -c equil.rst -r equil1.rst -x equil1.nc -ref equil.rst" >> fin_2.sh;
echo "pmemd.cuda -O -i prod.in -o prod1.out -p com-sol1.prmtop -c equil1.rst -r prod1.rst -x prod1.nc -ref equil1.rst" >> fin_2.sh;

echo "fin_2.sh created successfully!";