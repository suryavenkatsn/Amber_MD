# Amber_MD

A simple collection of Bash scripts for setting up and running molecular dynamics simulations of protein-ligand systems using AMBER.

This repository includes helper scripts for:
- protein preparation
- ligand parameterization
- complex assembly
- minimization and solvation
- MD input generation
- production MD execution
- basic trajectory analysis

## Repository contents

- `Amber_prtprep.sh` — prepares the protein structure with LEaP.
- `Amber_ligprep.sh` — prepares the ligand and generates AMBER parameter files.
- `Amber_comprep.sh` — combines protein and ligand into a complex and parameterizes it.
- `Amber_min-solv.sh` — runs minimization and solvation of the complex.
- `Amber_mdinput.sh` — creates the required input files for equilibration and production MD.
- `Amber_mdrun.sh` — runs the AMBER MD steps using `pmemd.cuda`.
- `Amber_trajanalysis.sh` — performs basic trajectory analysis and converts `.agr` output to PNG plots.

## Typical workflow

1. Prepare the protein:
   ```bash
   ./Amber_prtprep.sh 3tyv.pdb
   ```

2. Prepare the ligand:
   ```bash
   ./Amber_ligprep.sh UNK.mol2 1
   ```

3. Build the protein-ligand complex:
   ```bash
   ./Amber_comprep.sh 3tyv.pdb UNK.mol2
   ```

4. Minimize and solvate the complex:
   ```bash
   ./Amber_min-solv.sh 3tyv.pdb UNK.mol2
   ```

5. Generate MD input files:
   ```bash
   ./Amber_mdinput.sh 20
   ```

6. Run the simulation:
   ```bash
   ./Amber_mdrun.sh 20 0
   ```

7. Analyze trajectory output:
   ```bash
   ./Amber_trajanalysis.sh 20 prod1.nc
   ```

## Requirements

- AMBER installed and configured
- `AMBERHOME` environment variable set
- Python 3 available
- Common AMBER tools such as `tleap`, `sander`, `pmemd.cuda`, `cpptraj`, and `gracebat`

## Notes

- These scripts are designed as workflow helpers for a protein-ligand MD study.
- The example commands assume the ligand is named `UNK.mol2` and the protein structure is a PDB file.
- The scripts expect the necessary input files to be present in the working directory.

## License

This project is provided as-is for research and workflow automation purposes.
