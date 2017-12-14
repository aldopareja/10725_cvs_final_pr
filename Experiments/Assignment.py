
# coding: utf-8

# In[25]:


# Solve a generalized assignment problem between the different tracklets 
# setting similarity weights on the assignments such that we maximize the
# total assignment weigthed objective and match the most likely tracklets
from gurobipy import *
from numpy import *
import os
import glob


# In[27]:


directory = os.path.join("c:\\","path")

for root,dirs,files in os.walk(directory):
    for file in files:
        if file.endswith(".csv"):
            f=open(file, 'r')
           #  perform calculation
            f.close()


# In[66]:


import fnmatch
import os

matches = []
for root, dirnames, filenames in os.walk(cwd):
    for filename in fnmatch.filter(filenames, 'Tij*.csv'):
        file_path = os.path.join(root, filename)
        P = loadtxt(open(root + '/' + filename, "rb"), delimiter=",")
        print root
        numT = shape(P)[0]
        numC = shape(P)[1]

        T=range(numT)
        C=range(numC)
        
        # Initialize the model
        m=Model("Assignment")
        
        # Define the binary variables Xs
        X = []
        for t in T:
            X.append([])
            for c in C:
                X[t].append(m.addVar(vtype=GRB.BINARY,name="X%d%d"% (t, c)))

        # Set the optimization direction
        m.update()
        m.modelSense = GRB.MAXIMIZE
        
        
        # Define the assignment constraints
        constraintT = []
        constraintC = []

        # One variable assigned per column
        for t in range(numT):
            constraintT.append(m.addConstr(quicksum(X[t][c] for c in range(numC))
                                           <= 1 ,'constraintT%d' % t))

        # One variable assigned per row
        for c in range(numC):
            constraintT.append(m.addConstr(quicksum(X[t][c] for t in range(numT))
                                           <= 1 ,'constraintC%d' % t))
        
        
        # Define objective
        m.setObjective(quicksum(quicksum([X[t][c]*P[t][c] 
                                for c in range(numC)]) 
                                for t in range(numT)))

        m.update()
        
        # Solve the optimization problem
        m.optimize()
        
        # Print runtime and solution

        print 'runtime is',m.Runtime, 's'

        Xsol = zeros((numT,numC))
        # Print solution
        if m.status == GRB.Status.OPTIMAL:
            for t in range(numT):
                for c in range(numC):
                    if X[t][c].x > 0.5:
                        print('%g -> %g' % (t, c))
                        Xsol[t][c] = 1
        print Xsol
        name_sol = root + "/AssignmentT.csv"
        savetxt(name_sol, Xsol, delimiter=",")


# In[51]:





# In[52]:





# In[53]:





# In[60]:




