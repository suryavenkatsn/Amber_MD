import matplotlib.pyplot as plt
import numpy as np 
x = [1,2,3]
y = [2,4,1]
plt.plot(x,y)
plt.xlabel('x - axis')
plt.ylabel('y - axis')
plt.title('My first graph!')
plt.savefig("test.png", dpi=150)