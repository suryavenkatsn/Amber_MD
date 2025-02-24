#PBS -N frCOCO_11
#PBS -j oe
#PBS -m ae
#PBS -q serial8core
#PBS -l nodes=1:ppn=1
#PBS -l walltime=6:00:00
#PBS -o zzz.$PBS_JOBID.frCOCO_11
cd $PBS_O_WORKDIR
NP=$(wc -l < $PBS_NODEFILE)
cd $PBS_O_WORKDIR
$AMBERHOME/exe/mm_pbsa.pl extract-coord.in > extract_coords.log
