#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will convert .nc trajectory format to .mdcrd format"
    echo ""
    echo "Usage: $0 <traj1> <start> <end>"
    echo ""
    echo "Example: $0 prod1 0 25000"
    echo "The analysis will be done based on the inputs from the flags"
    echo 
    exit
fi

# Removing exisiting files to avoid duplication
rm nc_mdcrd.in;

# nc to mdcrd convertion

echo "trajin $1.nc $2 $3 1" >> nc_mdcrd.in;
echo "reference com-sol1.inpcrd" >> nc_mdcrd.in;
echo "trajout $1.mdcrd" >> nc_mdcrd.in;

cpptraj -p com-sol1.prmtop -i nc_mdcrd.in;

echo "**************************************************";
echo "Trajectory convertion is done successfully!";
echo "**************************************************";