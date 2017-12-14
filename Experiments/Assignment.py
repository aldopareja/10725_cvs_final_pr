
# coding: utf-8

# In[25]:


# Solve a generalized assignment problem between the different tracklets 
# setting similarity weights on the assignments such that we maximize the
# total assignment weigthed objective and match the most likely tracklets
from gurobipy import *
from numpy import *
import os
import fnmatch


# In[152]:


cwd = os.getcwd()
matches = []
for root, dirnames, filenames in os.walk(cwd):
    for filename in fnmatch.filter(filenames, 'Pij_2.csv'):
        file_path = os.path.join(root, filename)
        P = loadtxt(open(root + '/' + filename, "rb"), delimiter=",")
        print root
        print P
        numT = shape(P)[0]
        try:
            numC = shape(P)[1]
        except:
            numC = 0;    

        print numC
        T=range(numT)
        C=range(numC)

        # Initialize the model
        m=Model("Assignment")

        # Define the binary variables Xs
        X = []
        for t in T:
            X.append([])
            if numC != 0:
                for c in C:
                    X[t].append(m.addVar(vtype=GRB.BINARY,name="X%d%d"% (t, c)))
            else:
                X[t].append(m.addVar(vtype=GRB.BINARY,name="X%d%d"% (t, 0)))

        # Set the optimization direction
        m.update()
        m.modelSense = GRB.MAXIMIZE


        # Define the assignment constraints
        constraintT = []
        constraintC = []


        if numC != 0:
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
        else:
            # One variable assigned per column
            for t in range(numT):
                constraintT.append(m.addConstr(X[t][0]<= 1 ,'constraintT%d' % t))  

            # One variable assigned per row
            constraintT.append(m.addConstr(quicksum(X[t][0] for t in range(numT))
                                               <= 1 ,'constraintC%d' % t))

            # Define objective                 
            m.setObjective(quicksum(X[t][0]*P[t] for t in range(numT)))



        m.update()

        # Solve the optimization problem
        m.optimize()

        # Print runtime and solution

        print 'runtime is',m.Runtime, 's'
        print m


        if numC != 0:
            Xsol = zeros((numT,numC))
        else:
            Xsol = zeros(numT)
        # Print solution
        if m.status == GRB.Status.OPTIMAL:
            for t in range(numT):
                if numC != 0:
                    for c in range(numC):
                        if X[t][c].x > 0.5:
                            print('%g -> %g' % (t, c))
                            Xsol[t][c] = 1
                else:
                    if X[t][0].x > 0.5:
                        print('0 -> %g' % (t))
                        Xsol[t] = 1
        print Xsol
        name_sol = root + "/Assignment.csv"
        if numC != 0:
            savetxt(name_sol, Xsol, delimiter=",")
        else:
            savetxt(name_sol, Xsol[None], delimiter=",")
        

