#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
import pandas as pd
import seaborn as sb


# In[2]:


#extract the content of the working directory and pull out the csv wanted
wkd = os.listdir()
wkd_1 = []
for i in wkd:
    if i.startswith("PRED_") and i.endswith(".csv"):
        wkd_1.append(i)


# In[3]:


#Extracting all the csv and appending into one file to get the final list of unique column 1
x = pd.read_csv(wkd_1[0],header=None)
clone = x
p = 1
while p < len(wkd_1):
    k = pd.read_csv(wkd_1[p],header=None)
    clone = pd.concat([clone,k],join = "inner")
    p = p+1
    
ent = clone[0].unique()  #extracting the unique first column of the whole csv
par = pd.DataFrame(ent)  #Assigning it to the variable
        


# In[4]:


s = 0
w = 1
emp = []
for i in par[0]:
    emp.append("MERGER")
dat = {'head':list(par[0]),"dum":emp}
df = pd.DataFrame(data= dat)
df3 = df.copy()
while s < len(wkd_1):
    l = pd.read_csv(wkd_1[s],header = None)  
    col1 = []
    col2 = []
    ind = []
    for o in par[0]:
        t = 0
        while t < len(l[0]):
            #print(l[0][t])
            if o == l[0][t]:
                ind.append(l[0][t])
                col1.append(l[1][t])
                col2.append(l[2][t])
            t = t+1
    d = {'head':ind,str(w):col1,str(w+1):col2}
    df2 = pd.DataFrame(data=d)
    df3 = df3.join(df2.set_index('head'),on='head')
    s = s+1
    w = w+2
    
    


# In[5]:


df3.to_csv("compiled.csv")




