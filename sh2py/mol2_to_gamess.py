#!/usr/bin/env python3

from __future__ import annotations

import argparse
import re
from pathlib import Path

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


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("mol2", type=Path)
    parser.add_argument("-o", "--output", type=Path, default=Path("gamess_data.txt"))
    args = parser.parse_args()

    atoms = read_mol2_atoms(args.mol2)

    with args.output.open("w") as handle:
        handle.write("RESP single-point calculation\n")
        handle.write("C1\n")
        for element, atomic_number, x, y, z in atoms:
            handle.write(
                f"{element:<3s} {atomic_number:8.1f}"
                f" {x:18.10f} {y:18.10f} {z:18.10f}\n"
            )

    print(f"Wrote {len(atoms)} atoms to {args.output}")


if __name__ == "__main__":
    main()