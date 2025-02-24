#!/bin/bash
if [ ! -n "$1" ];then
    echo ""
    echo "This script will check Disulphide bonds in the input pdb file"
    echo ""
    echo "Usage: $0 <protein name>"
    echo ""
    echo "Example: $0 3tyv"
    echo "This will get the details of disulphide bonds in the pdb '3tyv'"
    echo ""
    exit
fi


echo ""
echo "**************************************************"
echo Name of the Protein: $1
echo "**************************************************"
echo ""

echo "PDB ID: $1" >> ssbond.txt
grep -i 'SSBOND' $1 >> ssbond.txt



echo ""
echo "--------------------------------------------------"
echo ssbond details of $1 is added to ssbond.txt
echo "--------------------------------------------------"
echo ""



