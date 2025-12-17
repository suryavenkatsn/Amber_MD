# ligand_preparation.py
import os
import argparse
import subprocess
from pathlib import Path

def run_cmd(cmd, cwd=None):
    print(f"\n>>> Running: {cmd}")
    result = subprocess.run(cmd, shell=True, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode != 0:
        print(result.stderr.decode())
        raise RuntimeError(f"Command failed: {cmd}")
    return result.stdout.decode()

def extract_charge_from_sdf(ligand):
    txt_file = f"TotQ_{ligand}.txt"
    sdf_file = f"{ligand}.sdf"
    with open(txt_file, 'w') as out:
        subprocess.run(f"grep -A 1 'i_epik_Tot_Q' {sdf_file}", shell=True, stdout=out)
    with open(txt_file) as f:
        lines = f.readlines()
    return lines[-1].strip()



def prepare_ligand(ligand, charge, amber_home):
    lig_dir = f"UNK_{ligand}"
    os.makedirs(lig_dir, exist_ok=True)

    run_cmd(
    f"antechamber -i ../{ligand}.mol2 -fi mol2 -o {ligand}-ac.mol2 -fo mol2 -nc {charge} -c bcc -dr no",
    cwd=lig_dir
    )

    run_cmd(
    f"{amber_home}/bin/parmchk2 -i {ligand}-ac.mol2 -f mol2 -o frcmod.UNK",
    cwd=lig_dir
    )


    # run_cmd(f"antechamber -i {ligand}.mol2 -fi mol2 -o {lig_dir}/{ligand}-ac.mol2 -fo mol2 -nc {charge} -c bcc -dr no")
    # run_cmd(f"{amber_home}/bin/parmchk2 -i {lig_dir}/{ligand}-ac.mol2 -f mol2 -o {lig_dir}/frcmod.UNK")

    leap_input = f"""source {amber_home}/dat/leap/cmd/oldff/leaprc.ff99SB
source {amber_home}/dat/leap/cmd/leaprc.gaff
UNK = loadmol2 {ligand}-ac.mol2
check UNK
loadamberparams frcmod.UNK
saveoff UNK UNK.lib
saveamberparm UNK UNK.prmtop UNK.inpcrd
savepdb UNK UNKlig.pdb
quit
"""
    in_file = f"{lig_dir}/ligprp_{ligand}.in"
    with open(in_file, 'w') as f:
        f.write(leap_input)

    run_cmd(f"tleap -f ligprp_{ligand}.in", cwd=lig_dir)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-l", "--ligand", required=True, help="Ligand mol2 file (without extension)")
    args = parser.parse_args()

    ligand_path = args.ligand
    ligand = Path(ligand_path).stem
    amber_home = os.getenv("AMBERHOME")

    if not amber_home:
        raise EnvironmentError("AMBERHOME environment variable not set")

    if not Path(f"{ligand}.mol2").exists():
        raise FileNotFoundError(f"{ligand}.mol2 not found.")
    if not Path(f"{ligand}.sdf").exists():
        raise FileNotFoundError(f"{ligand}.sdf not found for charge extraction.")

    charge = extract_charge_from_sdf(ligand)
    prepare_ligand(ligand, charge, amber_home)

    print("\n✅ Ligand preparation complete.")

if __name__ == "__main__":
    main()
