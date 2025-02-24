#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will concat two trajectories"
    echo ""
    echo "Usage: $0 <traj1.nc> <start> <end> <traj2.nc> <start> <end> <traj-all.nc>"
    echo ""
    echo "Example: $0 prod1.nc 0 25000 prod2.nc 0 25000 prod-all.nc"
    echo "This will concat both trajectories and save a new trajectory in the name of prod-all.nc"
    echo 
    exit
fi


# Removing exisiting files to avoid duplication
rm concat.in;

# Trajectory Concatenation

echo "trajin $1 $2 $3 1" >> concat.in;
echo "trajin $4 $5 $6 1" >> concat.in;
echo "reference com-sol1.inpcrd" >> concat.in;
echo "trajout $7" >> concat.in;

cpptraj -p com-sol1.prmtop -i concat.in > concat.out;

echo "**************************************************";
echo "Trajectory concatination is done successfully!";
echo "**************************************************";