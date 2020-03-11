import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

# Importing the dataset
dataset = pd.read_csv('F2.csv')
X = dataset.iloc[:, 0:2].values
y = dataset.iloc[:, 2].values

# Splitting the dataset into the Training set and Test set
from sklearn.model_selection import train_test_split 
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=0)

"""
# Scaling
from sklearn.preprocessing import StandardScaler
sc_X = StandardScaler()
X_train = sc_X.fit_transform(X_train)
X_test = sc_X.transform(X_test)
"""

# Fitting Linear Regression to the dataset
from sklearn.linear_model import LinearRegression
lin_reg = LinearRegression()
lin_reg.fit(X, y)

from sklearn.metrics import mean_squared_error, r2_score


print('coef:\n',lin_reg.coef_)
print('intercept:\n',lin_reg.intercept_)
print('score:\n',lin_reg.score(X_test, y_test))


y_pred = lin_reg.predict(X)
print ('X=',X)
print('y_pred:', y_pred)



rmse = np.sqrt(mean_squared_error(y,y_pred))
r2 = r2_score(y,y_pred)
print('rmse\n',rmse)
print('r2\n',r2)

print('--------------------- Polynomia Regression -----------------------')

# Fitting Polynomial Regression to the dataset
from sklearn.preprocessing import PolynomialFeatures
poly_reg = PolynomialFeatures(degree=4)
X_poly = poly_reg.fit_transform(X)
pol_reg = LinearRegression()
pol_reg.fit(X_poly, y)


print('coef:\n',pol_reg.coef_)
print('intercept:\n',pol_reg.intercept_)



X_test_poly = poly_reg.fit_transform(X_test)
print('score:\n',pol_reg.score(X_test_poly, y_test))


y_poly_pred = pol_reg.predict(X_poly)

rmse = np.sqrt(mean_squared_error(y,y_poly_pred))
r2 = r2_score(y,y_poly_pred)
print('rmse\n',rmse)
print('r2\n',r2)



print('--------------------  Predict ---------------------')
dataset=pd.read_csv('selectedSimEval.txt')

AX= dataset.iloc[:, 1:4].values





Ay_pred = lin_reg.predict(np.delete(AX,1, axis=1))

AX_poly=poly_reg.fit_transform(np.delete(AX,1, axis=1))
Ay_poly_pred = pol_reg.predict(AX_poly)


Ay_pred=Ay_pred.reshape(len(Ay_pred),1)
Ay_poly_pred=Ay_poly_pred.reshape(len(Ay_poly_pred),1)

AX= dataset.iloc[:, 0:4].values



AXy= np.concatenate((AX,Ay_pred), axis=1)
AXy_poly= np.concatenate((AX,Ay_poly_pred), axis=1)



pd.DataFrame(AXy).to_csv("LineReg2.csv")
pd.DataFrame(AXy_poly).to_csv("PolyReg2.csv")
















