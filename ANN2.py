# Import required libraries
import pandas as pd
import numpy as np 
import matplotlib.pyplot as plt
import sklearn
from sklearn.neural_network import MLPClassifier
from sklearn.neural_network import MLPRegressor

# Import necessary modules
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error
from math import sqrt
from sklearn.metrics import r2_score


dataset = pd.read_csv('F2_10.csv')
X = dataset.iloc[:, 0:2].values
y = dataset.iloc[:, 2].values



X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.30, random_state=40)
print(X_train.shape); print(X_test.shape)


from sklearn.neural_network import MLPClassifier
import statsmodels.api as sm

##X_train = sm.add_constant(X_train)
##X_test = sm.add_constant(X_test)

mlp = MLPClassifier(hidden_layer_sizes=(8,8,8), activation='relu', solver='adam', max_iter=500)
mlp.fit(X_train,y_train)

predict_train = mlp.predict(X_train)
predict_test = mlp.predict(X_test)



from sklearn.metrics import classification_report,confusion_matrix
print(confusion_matrix(y_train,predict_train))
print(classification_report(y_train,predict_train))



print(confusion_matrix(y_test,predict_test))
print(classification_report(y_test,predict_test))



print('--------------------  Predict ---------------------')
dataset=pd.read_csv('selectedSimEval.txt')

AX= dataset.iloc[:, 1:4].values

AX=np.delete(AX,1, axis=1)


##AX = sm.add_constant(AX)

Ay_pred = mlp.predict(AX)


Ay_pred=Ay_pred.reshape(len(Ay_pred),1)


AX= dataset.iloc[:, 0:4].values

AXy= np.concatenate((AX,Ay_pred), axis=1)

pd.DataFrame(AXy).to_csv("MLP2.csv")





