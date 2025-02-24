import matplotlib.pyplot as plt
import numpy as np 

plt.plot(*np.loadtxt("FINAL_DECOMP_MMPBSA.dat",unpack=True), linewidth=2.0)
plt.title('Res DC')
plt.savefig("test.png", dpi=150)