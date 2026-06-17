#!/usr/bin/env python3
import re
import sys

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

    print(f"Total charge = {total_charge:.4f}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} input.mol2 output.mol2")
        sys.exit(1)

    process_mol2(sys.argv[1], sys.argv[2])