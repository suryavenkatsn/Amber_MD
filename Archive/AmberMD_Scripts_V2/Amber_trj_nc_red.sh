#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will reduce the file size of .nc trajectory file"
    echo ""
    echo "Usage: $0 <traj1> <start> <end> <frame interval>"
    echo ""
    echo "Example: $0 prod1 0 25000 10"
    echo "This will reduce the size by 10 folds"
    echo 
    exit
fi

# Removing exisiting files to avoid duplication
rm nc_red.in;

# nc file size reduction

echo "trajin $1.nc $2 $3 $4" >> nc_red.in;
echo "reference com-sol1.inpcrd" >> nc_red.in;
echo "trajout $1_red.nc" >> nc_red.in;

cpptraj -p com-sol1.prmtop -i nc_red.in;

echo "**************************************************";
echo "Trajectory convertion is done successfully!";
echo "**************************************************";