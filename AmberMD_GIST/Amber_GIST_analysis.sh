#!/bin/bash
if [ ! -n "$1" ];then
	echo ""
	echo "This script will perform GIST calculation on the input trajectory"
	echo "Example: $0 prod1.nc";
	echo "This will perform GIST calculation on prod1.nc";
	echo
	exit
fi

# Ligand in PDB file. Make sure the CONNECT, TER and END are removed. Change HETATOM to ATOM
grep 'UNK' ../com-sol1.pdb > UNK.pdb

# cp $2 UNK.pdb
# sed -i '/TER/d' UNK.pdb
# sed -i '/END/d' UNK.pdb

# Analyzing the MD results with GIST
python3 FindCentroid.py -i UNK.pdb > centroid.txt

cent=$(tail -1 centroid.txt)

# Process the trajectory for GIST calculation
printf "parm ../com-sol1.prmtop
reference ../com-sol1.pdb
trajin $1
center :1-353 mass origin
autoimage
rms reference :1-353&!@H=
trajout prod_aligned.nc netcdf" > align.in

cpptraj -i align.in > align.out



printf "parm ../com-sol1.prmtop
trajin prod_aligned.nc 5000 last 10
$cent
go " > gist.in

cpptraj -i gist.in > gist.out

# Generating the Solvent Accessible Surface Area (SASA)
gistpp -i gist-gO.dx -op sasa -o SASA.dx

# Performing numerical combinations on GIST output with GISTPP
gistpp -i gist-Esw-dens.dx -op multconst -opt const 0.5 -o half-gist-Esw-dens.dx
gistpp -i gist-Eww-dens.dx -i2 half-gist-Esw-dens.dx -op add -o gist-Etot-dens.dx
gistpp -i gist-Etot-dens.dx -op multconst -opt const 0.125 -o gist-Etot.dx

gistpp -i gist-dTStrans-dens.dx -i2 gist-dTSorient-dens.dx -op add -o gist-dTStot-dens.dx
gistpp -i gist-dTStot-dens.dx -op multconst -opt const 0.125 -o gist-dTStot.dx
gistpp -i gist-Etot.dx -i2 gist-dTStot.dx -op sub -o gist-dA.dx

# Integration of solvent quantities over ligand pose volumes
gistpp -i gist-gO.dx -i2 UNK.pdb -op defbp -opt const 3 -o bp3_UNK.dx
# gistpp -i gist-gO.dx -i2 4QC.pdb -op defbp -opt const 3 -o bp3_4QC.dx

# to compare the water thermodynamic quantities found within those volumes
gistpp -i bp3_UNK.dx -i2 gist-Etot.dx -op mult -o UNK3_Etot.dx
gistpp -i bp3_UNK.dx -i2 gist-dTStot.dx -op mult -o UNK3_dTStot.dx
gistpp -i bp3_UNK.dx -i2 gist-dA.dx -op mult -o UNK3_dA.dx
# gistpp -i bp3_4QC.dx -i2 gist-Etot.dx -op mult -o 4QC3_Etot.dx
# gistpp -i bp3_4QC.dx -i2 gist-dTStot.dx -op mult -o 4QC3_dTStot.dx
# gistpp -i bp3_4QC.dx -i2 gist-dA.dx -op mult -o 4QC3_dA.dx


gistpp -i UNK3_Etot.dx -op sum
gistpp -i UNK3_dTStot.dx -op sum
gistpp -i UNK3_dA.dx -op sum
# gistpp -i 4QC3_Etot.dx -op sum
# gistpp -i 4QC3_dTStot.dx -op sum
# gistpp -i 4QC3_dA.dx -op sum

# Creating groups based on solvent properties
gistpp -i gist-gO.dx -i2 gist-Etot.dx -op filter2 -opt cutoff1 2.0 -opt gt1 -opt cutoff2 -0.25 -opt gt2 -o highGhighE.dx
gistpp -i highGhighE.dx -op group