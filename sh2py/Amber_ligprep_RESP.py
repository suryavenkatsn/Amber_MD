#!/usr/bin/env python3
import re
import sys
import os
import argparse
import subprocess
from pathlib import Path
import getpass


def run_cmd(cmd, cwd=None):
    print(f"\n>>> Running: {cmd}")
    result = subprocess.run(cmd, shell=True, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode != 0:
        print(result.stderr.decode())
        raise RuntimeError(f"Command failed: {cmd}")
    return result.stdout.decode()

def get_element(atom_name, atom_type):
    """
    Determine element from atom type first, then atom name.
    Examples:
        C.2    -> C
        O.co2  -> O
        H      -> H
    """
    elem = atom_type.split('.')[0]
    elem = re.sub(r'[^A-Za-z]', '', elem)

    if elem:
        return elem

    m = re.match(r'([A-Za-z]+)', atom_name)
    return m.group(1)[0] if m else atom_name[0]

def process_mol2(infile, outfile):
    in_atom_section = False
    atom_counter = 0
    total_charge = 0.0
    output_lines = []

    with open(infile) as f:
        for line in f:

            if line.startswith("@<TRIPOS>ATOM"):
                in_atom_section = True
                output_lines.append(line)
                continue

            if in_atom_section and line.startswith("@<TRIPOS>"):
                in_atom_section = False
                output_lines.append(line)
                continue

            if in_atom_section and line.strip():

                fields = line.split()

                atom_id = fields[0]
                atom_name = fields[1]
                x, y, z = fields[2:5]
                atom_type = fields[5]
                subst_id = fields[6]
                subst_name = fields[7]
                charge = float(fields[8])

                total_charge += charge

                atom_counter += 1
                element = get_element(atom_name, atom_type)

                # Rename sequentially according to atom order
                new_atom_name = f"{element}{atom_counter}"

                new_line = (
                    f"{int(atom_id):7d} "
                    f"{new_atom_name:<8s}"
                    f"{float(x):11.4f}"
                    f"{float(y):10.4f}"
                    f"{float(z):10.4f} "
                    f"{atom_type:<8s}"
                    f"{int(subst_id):6d} "
                    f"{subst_name:<8s}"
                    f"{charge:10.4f}\n"
                )

                output_lines.append(new_line)

            else:
                output_lines.append(line)

    with open(outfile, "w") as f:
        f.writelines(output_lines)

    #print(f"Total charge = {int(total_charge)}")
    #TOTAL_CHARGE=int(total_charge)
    return int(total_charge)


# Assign Multiplicity based on input from user or default to 1
def get_multiplicity():
    parser = argparse.ArgumentParser(description="Process mol2 file and determine multiplicity.")
    parser.add_argument("--multiplicity", type=int, default=1, help="Spin multiplicity (default: 1)")
    args = parser.parse_args()
    return args.multiplicity

ATOMIC_NUMBERS = {
    "H": 1, "He": 2,
    "Li": 3, "Be": 4, "B": 5, "C": 6, "N": 7, "O": 8,
    "F": 9, "Ne": 10,
    "Na": 11, "Mg": 12, "Al": 13, "Si": 14, "P": 15,
    "S": 16, "Cl": 17, "Ar": 18,
    "K": 19, "Ca": 20,
    "Br": 35, "I": 53,
}


def element_from_atom(atom_name: str, atom_type: str) -> str:
    candidate = atom_type.split(".")[0]
    candidate = re.sub(r"[^A-Za-z]", "", candidate)

    if candidate:
        candidate = candidate[0].upper() + candidate[1:].lower()
        if candidate in ATOMIC_NUMBERS:
            return candidate

    candidate = re.sub(r"[^A-Za-z]", "", atom_name)
    if not candidate:
        raise ValueError(f"Cannot determine element for atom {atom_name!r}")

    if len(candidate) >= 2:
        two_letter = candidate[0].upper() + candidate[1].lower()
        if two_letter in ATOMIC_NUMBERS:
            return two_letter

    one_letter = candidate[0].upper()
    if one_letter in ATOMIC_NUMBERS:
        return one_letter

    raise ValueError(
        f"Unsupported or unrecognized element for atom "
        f"name={atom_name!r}, type={atom_type!r}"
    )


def read_mol2_atoms(path: Path) -> list[tuple[str, int, float, float, float]]:
    atoms: list[tuple[str, int, float, float, float]] = []
    in_atom_section = False

    for line in path.read_text().splitlines():
        stripped = line.strip()

        if stripped == "@<TRIPOS>ATOM":
            in_atom_section = True
            continue

        if stripped.startswith("@<TRIPOS>") and in_atom_section:
            break

        if not in_atom_section or not stripped:
            continue

        fields = line.split()
        if len(fields) < 6:
            raise ValueError(f"Invalid MOL2 atom line: {line}")

        atom_name = fields[1]
        x, y, z = map(float, fields[2:5])
        atom_type = fields[5]

        element = element_from_atom(atom_name, atom_type)
        atoms.append((element, ATOMIC_NUMBERS[element], x, y, z))

    if not atoms:
        raise ValueError("No atoms found in the MOL2 ATOM section")

    return atoms


def main():
    parser = argparse.ArgumentParser(description="Process mol2 file and determine multiplicity.")
    parser.add_argument("--infile", type=str, required=True, help="Input MOL2 file")
    parser.add_argument("--outfile", type=str, default=None, help="Output MOL2 file")
    parser.add_argument("--multiplicity", type=int, default=1, help="Spin multiplicity (default: 1)")
    parser.add_argument("--resname", type=str, default="UNK", help="Residue name (default: UNK)")
    args = parser.parse_args()

    if args.outfile is None:
        args.outfile = f"{Path(args.infile).stem}_processed.mol2"

    # create a directory in the name of the ligand without mol2 extension and move into the directory for all executions
    ligand = Path(args.infile).stem
    ligand_dir = (f"UNK_{ligand}")
    os.makedirs(ligand_dir, exist_ok=True)
    run_cmd(f"cp {args.infile} {ligand_dir}/")
    os.chdir(ligand_dir)

    current_working_dir = os.getcwd()
    one_level_up = os.path.dirname(current_working_dir)

    # Fethch the AMBERHOME environment variable
    amber_home = os.environ.get('AMBERHOME')
    # Setting gamess environment variable
    os.environ['RUNGMS'] = "/usr/local/gamess/rungms"

    # Process mol2 from schrodinger to rename atoms and calculate total charge
    total_charge = process_mol2(args.infile, args.outfile)
 
    print(f"Total charge = {total_charge}")
    print(f"Spin multiplicity = {args.multiplicity}")

    # Convert the processed mol2 file to GAMESS input format
    mol2_to_gamess_script = Path(current_working_dir).parent / "mol2_to_gamess.py"
    subprocess.run(["python3", str(mol2_to_gamess_script), args.outfile, "-o", "gamess_data.txt"], check=True)

    with open("ligand.inp", "w") as f:
        f.write(f""" $CONTRL SCFTYP=RHF RUNTYP=ENERGY ICHARG={int(total_charge)}
          MULT={args.multiplicity} COORD=UNIQUE UNITS=ANGS
          MAXIT=200 $END
 $SYSTEM MWORDS=500 $END
 $SCF DIRSCF=.TRUE. CONV=1.0E-08 $END
 $BASIS GBASIS=N31 NGAUSS=6 NDFUNC=1 $END
 $GUESS GUESS=HUCKEL $END
 $ELPOT IEPOT=1 WHERE=PDC OUTPUT=PUNCH $END
 $PDC PTSEL=CONNOLLY CONSTR=NONE $END
 $DATA
""")

        with open("gamess_data.txt", "r") as gamess_file:
            gamess_data = gamess_file.read()
        f.write(gamess_data)
        f.write(" $END\n")

    # clear scratch directory for ligand and run GAMESS to generate ESP data
    #username = getpass.getuser()
    #run_cmd(f"rm -rf /scratch/{username}/ligand.*")
    run_cmd(f"rm -rf {ligand_dir}*")
    # run GAMESS to generate ESP data
    run_cmd("rungms ligand.inp 00 8 > ligand.log 2>&1")

    # checkpoint: verify GAMESS termination status in ligand.log
    with open("ligand.log", "r", encoding="utf-8", errors="ignore") as log_file:
        log_text = log_file.read()
    if "ABNORMALLY" in log_text:
        raise RuntimeError("GAMESS terminated abnormally. Check ligand.log for details.")
    if "EXECUTION OF GAMESS TERMINATED NORMALLY" not in log_text:
        raise RuntimeError("GAMESS termination status not found in ligand.log. Check log contents.")

    #run_cmd(f"cp /scratch/{username}/ligand.dat ligand.dat")
    run_cmd("espgen -i ligand.dat -o ligand.esp > espgen.log 2>&1")
    # run antechamber to generate the ac file for RESP fitting
    run_cmd(f"antechamber -i {args.outfile} -fi mol2 -o ligand.ac -fo ac -nc {int(total_charge)} -m {args.multiplicity} -dr no")
    ## Generate the two RESP fitting input files
    run_cmd("respgen -i ligand.ac -o resp1.in -f resp1")
    run_cmd("respgen -i ligand.ac -o resp2.in -f resp2")

    ## Run RESP stage 1
    run_cmd("resp -O -i resp1.in -o resp1.out -e ligand.esp -t resp1.qout")
    run_cmd("resp -O -i resp2.in -o resp2.out -e ligand.esp -t resp2.qout -q resp1.qout")

    # write the RESP charges into a new mol2 file
    run_cmd(f"antechamber -i ligand.ac -fi ac -o ligand_resp.mol2 -fo mol2 -c rc -cf resp2.qout -nc {int(total_charge)} -m {args.multiplicity} -rn {args.resname} -dr no")

    # generate the frcmod file for the ligand
    run_cmd(f"parmchk2 -i ligand_resp.mol2 -f mol2 -o frcmod.UNK -s gaff2")


    leap_input = f"""source {amber_home}/dat/leap/cmd/oldff/leaprc.ff99SB
    source {amber_home}/dat/leap/cmd/leaprc.gaff2
    {args.resname} = loadmol2 ligand_resp.mol2
    check {args.resname}
    loadamberparams frcmod.UNK
    saveoff {args.resname} UNK.lib
    saveamberparm {args.resname} UNK.prmtop UNK.inpcrd
    savepdb {args.resname} UNKlig.pdb
    quit
    """
    in_file = f"ligprp_{ligand}.in"
    with open(in_file, 'w') as f:
        f.write(leap_input)

    run_cmd(f"tleap -f ligprp_{ligand}.in > ligprp_{ligand}.out 2>&1")

if __name__ == "__main__":
    main()
    