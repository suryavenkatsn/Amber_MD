# This script runs PCA analysis on the trajectory files using the cpptraj module of AmberTools.
# It assumes the necessary input files (topology and trajectory) are in the directory one level up from the script's location.
import os
import subprocess
# Define the paths to the input files
topology_file = os.path.join(os.path.dirname(__file__), '..', 'com-sol1.prmtop')
trajectory_file = os.path.join(os.path.dirname(__file__), '..', 'prod1.nc')

# generate the cpptraj input file for PCA analysis
cpptraj_input = f"""parm {topology_file}
trajin {trajectory_file}
autoimage anchor @CA
rms first @N,C,CA
average @N,C,CA crdset trajaverage
createcrd trajectory
run
# create covariance matrix and projecting the trajectory onto the eigenvectors
crdaction trajectory rms ref trajaverage @N,C,CA
crdaction trajectory matrix covar name covmatrix @N,C,CA
runanalysis diagmatrix covmatrix out evecs.dat vecs 10 name eigenvectors nmwiz nmwizvecs 10 nmwizfile normalmodes.nmd nmwizmask @N,C,CA
crdaction trajectory projection modes eigenvectors beg 1 end 10 @N,C,CA out pca.dat crdframes 1,10000 #this number changes depending on the number of frames in your system
quit

clear all
readdata evecs.dat name eigenvectors
parm unboundstrip.top
parmwrite out modes.prmtop
runanalysis modes name eigenvectors trajout modes01.nc pcmin -150 pcmax 150 tmode 1 trajoutmask @N,C,CA trajoutfmt netcdf
#the modes.prmtop can be read in a visualization software to see the motions that correspond to each primary component"""

# Write the cpptraj input to a file
cpptraj_input_file = os.path.join(os.path.dirname(__file__), 'pca.in')
with open(cpptraj_input_file, 'w') as f:
    f.write(cpptraj_input)

# Run cpptraj with the generated input file
subprocess.run(['cpptraj', '-i', cpptraj_input_file, '>', 'pca.out'], check=True)

# Create colourmap for the PCA projection
subprocess.run(['python', 'colourmap.py', 'pca.dat', 'PCA', 'pca.png'], check=True)

