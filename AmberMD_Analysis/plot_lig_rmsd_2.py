import numpy as np
import matplotlib.pyplot as plt
import argparse
import glob
import os


def load_matrix(dat_file):
    # Load file, skip header line
    mat = np.loadtxt(dat_file, skiprows=1)

    # Remove first column (frame index)
    mat = mat[:, 1:]

    return mat


def plot_matrix(mat, out_file):
    plt.figure(figsize=(7, 6))
    plt.imshow(mat, origin="lower", cmap="viridis", vmin=0, vmax=15)
    plt.colorbar(label="Ligand RMSD (Å)")
    plt.xlabel("Frame")
    plt.ylabel("Frame")

    plt.savefig(out_file, dpi=300, bbox_inches="tight")
    plt.close()


def main():
    parser = argparse.ArgumentParser(
        description="Plot ligand RMSD matrices from cpptraj rms2d output"
    )
    parser.add_argument(
        "-i", "--input",
        help="Input RMSD matrix .dat file (optional)"
    )
    parser.add_argument(
        "--pattern",
        default="ligand_rmsd_matrix_*.dat",
        help="Glob pattern to auto-detect RMSD matrix files"
    )
    parser.add_argument(
        "--format",
        choices=["tiff", "png"],
        default="tiff",
        help="Output image format (default: tiff)"
    )

    args = parser.parse_args()

    # Determine input files
    if args.input:
        dat_files = [args.input]
    else:
        dat_files = sorted(glob.glob(args.pattern))

    if not dat_files:
        raise RuntimeError("No RMSD matrix .dat files found")

    for dat in dat_files:
        print(f"\nProcessing: {dat}")

        mat = load_matrix(dat)

        # Sanity check
        print(
            f"  RMSD range (Å): {mat.min():.2f} – {mat.max():.2f}"
        )

        base = os.path.splitext(os.path.basename(dat))[0]
        out_file = f"{base}.{args.format}"

        plot_matrix(mat, out_file)

        print(f"  Saved: {out_file}")


if __name__ == "__main__":
    main()
