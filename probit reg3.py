# -*- coding: utf-8 -*-
"""
Created on Fri Dec 21 18:59:49 2018

@author: Nhan Tran
"""

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

# Importing the dataset
dataset = pd.read_csv('regression3_10.csv')
X = dataset.iloc[:, 0:3].values
y = dataset.iloc[:, 3].values

y=(y==1)




from statsmodels.discrete.discrete_model import Probit

import statsmodels.api as sm

X = sm.add_constant(X)


model = Probit(y, X.astype(float))
probit_model = model.fit()

print(probit_model.summary())




print('-------------------- Predict ---------------------')
dataset=pd.read_csv('selectedSimEval.txt')

AX= dataset.iloc[:, 1:4].values

AX = sm.add_constant(AX)



Ay_pred = probit_model.predict(AX)




Ay_pred=Ay_pred.reshape(len(Ay_pred),1)


AX= dataset.iloc[:, 0:4].values

AXy= np.concatenate((AX,Ay_pred), axis=1)




pd.DataFrame(AXy).to_csv("ProbitRegResult3.csv")















