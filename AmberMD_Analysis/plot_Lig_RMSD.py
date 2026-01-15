import numpy as np
import matplotlib.pyplot as plt

# Load file, skip header line
mat = np.loadtxt("ligand_rmsd_matrix.dat", skiprows=1)

# Remove first column (frame index)
mat = mat[:, 1:]

# Sanity check
print("RMSD range (Å):", mat.min(), mat.max())

# Plot
plt.figure(figsize=(7, 6))
plt.imshow(mat, origin="lower", cmap="viridis", vmin=0, vmax=15)
plt.colorbar(label="Ligand RMSD (Å)")
plt.xlabel("Frame")
plt.ylabel("Frame")

plt.savefig("ligand_rmsd_matrix.tiff", dpi=300, bbox_inches="tight")
#plt.savefig("ligand_rmsd_matrix.png", dpi=300)
plt.close()