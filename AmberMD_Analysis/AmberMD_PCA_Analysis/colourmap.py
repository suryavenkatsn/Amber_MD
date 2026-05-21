import numpy as np
import matplotlib as mlb
import matplotlib
matplotlib.use("Agg")
from matplotlib import pyplot as plt
from scipy.stats import gaussian_kde
import sys
a = np.loadtxt(sys.argv[1])
pc1 = a[:,1]
pc2 = a[:,2]
xy = np.vstack([pc1,pc2])
z = gaussian_kde(xy)(xy)
fig, ax = plt.subplots()
ax.scatter(pc1,pc2, c=z, s=5)
#plt.xlim([-80,80])
#plt.ylim([-70,70])
plt.xlabel('pc1',fontsize=14)
plt.ylabel('pc2', fontsize=14)
plt.title(sys.argv[3], fontsize=20)
plt.savefig(sys.argv[2])
#plt.show()