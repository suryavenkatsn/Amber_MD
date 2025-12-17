# system_preparation.py
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

def prepare_complex(ligand):
    lig_dir = f"UNK_{ligand}"
    with open("rec.pdb") as rec, open(f"{lig_dir}/UNKlig.pdb") as lig, open("complex.pdb", 'w') as out:
        for line in rec:
            if not line.startswith("END"):
                out.write(line)
        out.writelines(lig.readlines())

    leap_input = f"""source {os.environ['AMBERHOME']}/dat/leap/cmd/oldff/leaprc.ff99SB
source {os.environ['AMBERHOME']}/dat/leap/cmd/leaprc.zinc
source {os.environ['AMBERHOME']}/dat/leap/cmd/leaprc.gaff
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
Keep protein fixed
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

def estimate_ions_and_volume(ligand):
    amber_home = os.getenv("AMBERHOME")
    run_cmd(f"{amber_home}/bin/ambpdb -p com.prmtop -c complexmin.rst > complexmin.pdb")

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
    run_cmd("tleap -f solv_c.in > leap.log")

    with open("leap.log") as f:
        lines = f.readlines()
    charge = float([line for line in lines if "Total unperturbed charge" in line][0].split()[-1])
    vol = float([line for line in lines if "Volume" in line][0].split()[1])

    ion_type = 'Cl-' if charge >= 0 else 'Na+'
    litre = 1e-27
    vl_litre = vol * litre
    sc = 0.15
    c = sc * 1000 * (6.022e23) / 1e3
    ions = round(vl_litre * c)

    print(f"Ion to neutralize system: {ion_type}")
    print(f"Volume of box (litres): {vl_litre:.4e}")
    print(f"Ions needed for 150mM NaCl: {ions}")

    return ion_type, ions

def solvate_system(ligand, ion_type, ions):
    amber_home = os.getenv("AMBERHOME")
    run_cmd(f"{amber_home}/bin/ambpdb -p com.prmtop -c complexmin.rst > complexmin.pdb")

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
    parser.add_argument("-l", "--ligand", required=True, help="Ligand name (without extension)")
    args = parser.parse_args()

    protein = args.protein
    ligand = Path(args.ligand).stem
    amber_home = os.getenv("AMBERHOME")

    if not amber_home:
        raise EnvironmentError("AMBERHOME environment variable not set")
    if not Path(protein).exists():
        raise FileNotFoundError(f"{protein} not found.")

    prepare_protein(protein, amber_home)
    prepare_complex(ligand)
    minimize_system()
    ion_type, ions = estimate_ions_and_volume(ligand)
    solvate_system(ligand, ion_type, ions)

    print("\n✅ System preparation complete. Ready for MD.")

if __name__ == "__main__":
    main()
