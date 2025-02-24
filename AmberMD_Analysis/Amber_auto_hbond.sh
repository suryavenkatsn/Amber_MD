#!/bin/bash
if [ ! -n "$1" ];then
	echo "Usage: $0 -t <trajectory>"
	echo ""
	echo "Example: $0 -t prod1.nc"
	echo ""
	exit
fi

while getopts t: flag
do
	case "${flag}" in
		t) traj=${OPTARG};;
	esac
done

# Frame calculation
x=500; # Frames per ns
y=500000; # Time Steps per ns

if [ ! -e prod2.out ]; then
	ts=$(awk '/nstlim/ { print $1 }' prod1.out | awk -F '[=,]' '{ print $2 }');
else
	ts1=$(awk '/nstlim/ { print $1 }' prod1.out | awk -F '[=,]' '{ print $2 }');
	ts2=$(awk '/nstlim/ { print $1 }' prod2.out | awk -F '[=,]' '{ print $2 }');
	ts=$((ts1 + ts2));
fi

tp=$((ts / y));
z=$((tp / 5));


if [ ! -e $traj ];then
    echo "";
    echo "---------------------------------------------------------";
    echo "Analysis can't be done as $traj is not found";
    echo "---------------------------------------------------------";
    echo "";
    exit
fi

# Current directory
dir=$(pwd | grep -o '[^/]*$')

# Residue No. Assignment and timestep calculation
lignum=$(awk '/UNK/ { print $5;exit; }' com.pdb);
recend=$((lignum - 1))


# Frame calculation
a=500; # Frames per ns
b=500000; # Time Steps per ns
tp=$((ts / b));
frame=$((tp * a));

# Hbond Calculation

rm hbond.in;
rm hbond.out;
rm -r hbond_$tp/

mkdir hbond_$tp

echo "trajin prod1.nc 2000 $frame 1" >> hbond.in
echo "hbond contacts :1-$lignum avgout avg_$dir.dat series uuseries hbond.gnu nointramol" >> hbond.in
echo "go" >> hbond.in
echo "lifetime contacts[solutehb] out contacts-lifetime.dat" >> hbond.in
echo "go" >> hbond.in

cpptraj -p com-sol1.prmtop -i hbond.in > hbond.out

echo "Hbond calculation - Done";
echo "**************************************************";

mv avg.dat contacts-lifetime.dat crv.contacts-lifetime.dat hbond.gnu hbond_$tp/
