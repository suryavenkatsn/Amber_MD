import matplotlib.pyplot as plt
import pandas as pd

data = pd.read_csv('PRED_Test_2.csv')

df = pd.DataFrame(data)

X = list(df.iloc[:, 0])
Y = list(df.iloc[:, 1])

plt.figure(figsize=(16,10))
plt.bar(X, Y, color = 'g')
plt.title('PRED - Test_2', fontsize = 20)
plt.xlabel('Residues')
plt.ylabel('Free Energy Contribution (kcal/mol)')
plt.savefig('pred_Test_2.png',bbox_inches='tight',dpi=150)
plt.close()
