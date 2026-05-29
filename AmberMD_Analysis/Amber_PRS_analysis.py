#!/usr/bin/env python3

"""
prs_analysis.py

Perform Perturbation Response Scanning (PRS) using:
    1. MD trajectory
    2. PCA eigenvectors (Amber cpptraj evecs.dat)
    3. ANM/NMA eigenvectors

using ProDy.

Author: OpenAI ChatGPT
Description:
    This script calculates PRS matrices and residue effectiveness/sensitivity
    profiles from:
        - MD trajectory
        - PCA modes
        - ANM/NMA modes

Requirements:
    pip install prody numpy pandas matplotlib seaborn

Example Usage
==============

1. PRS from trajectory:
-----------------------
python prs_analysis.py \
    --mode traj \
    --topology protein.pdb \
    --trajectory md.nc \
    --selection "protein and name CA"

2. PRS from PCA:
----------------
python prs_analysis.py \
    --mode pca \
    --topology avg.pdb \
    --pca evecs.dat \
    --nmodes 20

3. PRS from ANM:
----------------
python prs_analysis.py \
    --mode anm \
    --topology protein.pdb \
    --nmodes 20

Outputs
=======
1. prs_matrix.csv
2. prs_effectiveness.csv
3. prs_sensitivity.csv
4. prs_matrix.png
5. prs_profiles.png

"""

import argparse
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

from prody import *


# ============================================================
# Utility Functions
# ============================================================

def save_matrix_csv(matrix, outfile):
    df = pd.DataFrame(matrix)
    df.index.name = "Residue"
    df.to_csv(outfile)


def save_profile_csv(profile, outfile, label):
    df = pd.DataFrame({
        "Residue_Index": np.arange(1, len(profile) + 1),
        label: profile
    })
    df.to_csv(outfile, index=False)


def plot_prs_matrix(matrix, outfile):
    plt.figure(figsize=(10, 8))

    sns.heatmap(
        matrix,
        cmap="viridis",
        square=True,
        cbar_kws={"label": "PRS Response"}
    )

    plt.xlabel("Perturbed Residue")
    plt.ylabel("Responding Residue")
    plt.title("PRS Matrix")

    plt.tight_layout()
    plt.savefig(outfile, dpi=300)
    plt.close()


def plot_profiles(effectiveness, sensitivity, outfile):

    residues = np.arange(1, len(effectiveness) + 1)

    plt.figure(figsize=(12, 5))

    plt.plot(
        residues,
        effectiveness,
        label="Effectiveness",
        linewidth=2
    )

    plt.plot(
        residues,
        sensitivity,
        label="Sensitivity",
        linewidth=2
    )

    plt.xlabel("Residue Index")
    plt.ylabel("PRS Score")
    plt.title("PRS Profiles")

    plt.legend()
    plt.tight_layout()

    plt.savefig(outfile, dpi=300)
    plt.close()


# ============================================================
# Build Models
# ============================================================

def build_anm_model(atomgroup, nmodes):

    print("\n[INFO] Building ANM model...")

    anm = ANM("ANM")
    anm.buildHessian(atomgroup)
    anm.calcModes(n_modes=nmodes)

    return anm


def build_pca_model(atomgroup, trajectory, selection, nmodes):

    print("\n[INFO] Building PCA model from trajectory...")

    ensemble = Ensemble("MD")
    ensemble.setAtoms(atomgroup)

    traj = Trajectory(trajectory)
    traj.link(atomgroup)

    coords = []

    for frame in traj:
        coords.append(atomgroup.select(selection).getCoords())

    coords = np.array(coords)

    ensemble.setCoords(coords[0])
    ensemble.addCoordset(coords)

    pca = PCA("PCA")
    pca.buildCovariance(ensemble)
    pca.calcModes(n_modes=nmodes)

    return pca


def load_pca_from_cpptraj(atomgroup, pca_file, nmodes):

    """
    Reads cpptraj evecs.dat style eigenvector file.

    NOTE:
    -----
    This assumes eigenvectors are stored row-wise or
    sequentially in whitespace format.

    Modify parsing if your format differs.
    """

    print("\n[INFO] Reading PCA eigenvectors from:", pca_file)

    data = np.loadtxt(pca_file)

    n_atoms = atomgroup.numAtoms()
    ndim = n_atoms * 3

    eigenvectors = data[:nmodes, :ndim]

    covariance = np.dot(eigenvectors.T, eigenvectors)

    pca = PCA("PCA_from_cpptraj")
    pca.setCovariance(covariance)

    return pca


# ============================================================
# PRS Calculation
# ============================================================

def calculate_prs(atomgroup, model):

    print("\n[INFO] Performing PRS calculation...")

    prs_matrix, effectiveness, sensitivity = calcPerturbResponse(
        model,
        atoms=atomgroup
    )

    return prs_matrix, effectiveness, sensitivity


# ============================================================
# Main
# ============================================================

def main():

    parser = argparse.ArgumentParser(
        description="PRS analysis using ProDy"
    )

    parser.add_argument(
        "--mode",
        choices=["traj", "pca", "anm"],
        required=True,
        help="Input type"
    )

    parser.add_argument(
        "--topology",
        required=True,
        help="PDB topology"
    )

    parser.add_argument(
        "--trajectory",
        help="MD trajectory file"
    )

    parser.add_argument(
        "--pca",
        help="cpptraj PCA eigenvector file (evecs.dat)"
    )

    parser.add_argument(
        "--selection",
        default="protein and name CA",
        help="Atom selection"
    )

    parser.add_argument(
        "--nmodes",
        type=int,
        default=20,
        help="Number of modes"
    )

    parser.add_argument(
        "--prefix",
        default="prs",
        help="Output filename prefix"
    )

    args = parser.parse_args()

    # ========================================================
    # Load Structure
    # ========================================================

    print("\n[INFO] Loading topology...")

    structure = parsePDB(args.topology)

    atomgroup = structure.select(args.selection)

    if atomgroup is None:
        raise ValueError("Selection returned no atoms!")

    print(f"[INFO] Selected atoms: {atomgroup.numAtoms()}")

    # ========================================================
    # Build Model
    # ========================================================

    if args.mode == "anm":

        model = build_anm_model(
            atomgroup,
            args.nmodes
        )

    elif args.mode == "traj":

        if args.trajectory is None:
            raise ValueError("--trajectory required for traj mode")

        model = build_pca_model(
            atomgroup,
            args.trajectory,
            args.selection,
            args.nmodes
        )

    elif args.mode == "pca":

        if args.pca is None:
            raise ValueError("--pca required for pca mode")

        model = load_pca_from_cpptraj(
            atomgroup,
            args.pca,
            args.nmodes
        )

    else:
        raise ValueError("Invalid mode")

    # ========================================================
    # PRS
    # ========================================================

    prs_matrix, effectiveness, sensitivity = calculate_prs(
        atomgroup,
        model
    )

    # ========================================================
    # Save Outputs
    # ========================================================

    matrix_csv = f"{args.prefix}_matrix.csv"
    eff_csv = f"{args.prefix}_effectiveness.csv"
    sens_csv = f"{args.prefix}_sensitivity.csv"

    matrix_png = f"{args.prefix}_matrix.png"
    profiles_png = f"{args.prefix}_profiles.png"

    print("\n[INFO] Writing outputs...")

    save_matrix_csv(prs_matrix, matrix_csv)

    save_profile_csv(
        effectiveness,
        eff_csv,
        "Effectiveness"
    )

    save_profile_csv(
        sensitivity,
        sens_csv,
        "Sensitivity"
    )

    plot_prs_matrix(
        prs_matrix,
        matrix_png
    )

    plot_profiles(
        effectiveness,
        sensitivity,
        profiles_png
    )

    # ========================================================
    # Save Top Residues
    # ========================================================

    top_eff = np.argsort(effectiveness)[::-1][:10] + 1
    top_sens = np.argsort(sensitivity)[::-1][:10] + 1

    with open(f"{args.prefix}_summary.txt", "w") as f:

        f.write("Top Effective Residues\n")
        f.write("=======================\n")

        for r in top_eff:
            f.write(f"{r}\n")

        f.write("\nTop Sensitive Residues\n")
        f.write("=======================\n")

        for r in top_sens:
            f.write(f"{r}\n")

    print("\n[INFO] Done.")
    print(f"[INFO] Outputs written with prefix: {args.prefix}")


if __name__ == "__main__":
    main()