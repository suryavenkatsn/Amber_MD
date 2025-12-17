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

    run_cmd(f"antechamber -i {ligand}.mol2 -fi mol2 -o {lig_dir}/{ligand}-ac.mol2 -fo mol2 -nc {charge} -c bcc -dr no")
    run_cmd(f"{amber_home}/bin/parmchk2 -i {lig_dir}/{ligand}-ac.mol2 -f mol2 -o {lig_dir}/frcmod.UNK")

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

def prepare_protein(protein, amber_home):
    leap_input = f"""source {amber_home}/dat/leap/cmd/oldff/leaprc.ff99SB
source {amber_home}/dat/leap/cmd/leaprc.zinc
source {amber_home}/dat/leap/cmd/leaprc.gaff
pro = loadpdb {protein}
saveamberparm pro rec.prmtop rec.inpcrd
savepdb pro rec.pdb
quit
"""
    with open("prtprp.in", 'w') as f:
        f.write(leap_input)
    run_cmd("tleap -f prtprp.in")

def prepare_complex(ligand, amber_home):
    lig_dir = f"UNK_{ligand}"
    with open("rec.pdb") as rec, open(f"{lig_dir}/UNKlig.pdb") as lig, open("complex.pdb", 'w') as out:
        for line in rec:
            if not line.startswith("END"):
                out.write(line)
        out.writelines(lig.readlines())

    leap_input = f"""source {amber_home}/dat/leap/cmd/oldff/leaprc.ff99SB
source {amber_home}/dat/leap/cmd/leaprc.zinc
source {amber_home}/dat/leap/cmd/leaprc.gaff
loadamberparams {lig_dir}/frcmod.UNK
loadoff {lig_dir}/UNK.lib
complex = loadpdb complex.pdb
saveamberparm  complex com.prmtop com.inpcrd
savepdb complex com.pdb
quit
"""
    with open("comprp.in", 'w') as f:
        f.write(leap_input)
    run_cmd("tleap -f comprp.in")

def minimize_system():
    lignum = int(run_cmd("awk '/UNK/ { print $5; exit; }' com.pdb").strip())
    recend = lignum - 1

    with open("drug.in", 'w') as f:
        f.write(f"""Minimize drug coords (drug is resid) and xtal water
 &cntrl
  imin = 1,
  maxcyc = 1000,
  ncyc = 500,
  ntr = 1,
  ntb = 0,
  cut = 16.0,
/
10.0
RES 1 {recend}
END
END
""")

    with open("complexmin.in", 'w') as f:
        f.write("""Minimize water positions (and all hydrogens)
 &cntrl
  imin = 1,
  maxcyc = 1000,
  ncyc = 500,
  ntr = 1,
  ntb = 0,cut=16.0,
/
END
""")

    run_cmd("sander -O -i drug.in -o drug.out -p com.prmtop -c com.inpcrd -r drug.rst -x drug.mdcrd -ref com.inpcrd")
    run_cmd("sander -O -i complexmin.in -o complexmin.out -p com.prmtop -c drug.rst -r complexmin.rst -x complexmin.mdcrd -ref drug.rst")

def estimate_ions_and_volume(ligand, amber_home):
    run_cmd("{amber_home}/bin/ambpdb -p com.prmtop -c complexmin.rst > complexmin.pdb")

    lig_dir = f"UNK_{ligand}"
    leap_input = f"""source {amber_home}/dat/leap/cmd/oldff/leaprc.ff99SB
source {amber_home}/dat/leap/cmd/leaprc.zinc
source {amber_home}/dat/leap/cmd/leaprc.gaff
loadamberparams {lig_dir}/frcmod.UNK
loadoff {lig_dir}/UNK.lib
complex = loadpdb complexmin.pdb
solvatebox complex TIP3PBOX 10.0
charge complex
quit
"""
    with open("solv_c.in", 'w') as f:
        f.write(leap_input)
    run_cmd("tleap -f solv_c.in > solv_charge.out")

    with open("leap.log") as f:
        lines = f.readlines()
    charge = float([line for line in lines if "Total unperturbed charge" in line][0].split()[-1])
    vol = float([line for line in lines if "Volume" in line][0].split()[1])

    # Ion calculations (formerly ions_nacl.py)
    ion_type = 'Cl-' if charge >= 0 else 'Na+'
    print(f"Ion to neutralize system: {ion_type}")

    # Salt concentration calculation (formerly sc_calc.py)
    litre = 1e-27
    vl_litre = vol * litre
    sc = 0.15
    c = sc * 1000 * (6.022e23) / 1e3
    ions = round(vl_litre * c)
    print(f"Volume of box (litres): {vl_litre:.4e}")
    print(f"Ions needed for 150mM NaCl: {ions}")

    return ion_type, ions

def solvate_system(ligand, ion_type, ions, amber_home):
    run_cmd("{amber_home}/bin/ambpdb -p com.prmtop -c complexmin.rst > complexmin.pdb")

    lig_dir = f"UNK_{ligand}"
    with open("solv.in", 'w') as f:
        f.write(f"""source {amber_home}/dat/leap/cmd/oldff/leaprc.ff99SB
source {amber_home}/dat/leap/cmd/leaprc.zinc
source {amber_home}/dat/leap/cmd/leaprc.gaff
loadamberparams {lig_dir}/frcmod.UNK
loadoff {lig_dir}/UNK.lib
complex = loadpdb complexmin.pdb
solvatebox complex TIP3PBOX 10.0
charge complex
addIons complex {ion_type} 0
addIonsRand complex Na+ {ions} Cl- {ions}
saveamberparm complex com-sol1.prmtop com-sol1.inpcrd
savepdb complex com-sol1.pdb
quit
""")
    run_cmd("tleap -f solv.in")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--protein", required=True, help="Protein PDB file")
    parser.add_argument("-l", "--ligand", required=True, help="Ligand mol2 file (without extension)")
    args = parser.parse_args()

    protein = args.protein
    ligand_path = args.ligand
    ligand = Path(ligand_path).stem
    amber_home = os.getenv("AMBERHOME")

    if not amber_home:
        raise EnvironmentError("AMBERHOME environment variable not set")

    if not Path(protein).exists():
        raise FileNotFoundError(f"{protein} not found.")
    if not Path(f"{ligand}.mol2").exists():
        raise FileNotFoundError(f"{ligand}.mol2 not found.")
    if not Path(f"{ligand}.sdf").exists():
        raise FileNotFoundError(f"{ligand}.sdf not found for charge extraction.")

    charge = extract_charge_from_sdf(ligand)
    prepare_ligand(ligand, charge, amber_home)
    prepare_protein(protein, amber_home)
    prepare_complex(ligand)
    minimize_system()
    ion_type, ions = estimate_ions_and_volume()
    solvate_system(ligand, ion_type, ions)

    print("\n✅ All steps completed. System ready for MD simulation.")

if __name__ == "__main__":
    main()
