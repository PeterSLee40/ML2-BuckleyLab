# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
from keras.models import Sequential
from keras.layers import Dense
from sklearn.datasets import make_regression
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split  
import pandas as pd
from numpy import array
import numpy as np
print("importing has completed...")
# generate regression dataset
X, y = pd.read_csv("TSG_db2_2_input.csv"), pd.read_csv("TSG_db2_2_target.csv")

X_trainingSet, X_testSet, y_trainingSet, y_testSet = train_test_split(X, y, test_size=.2)
Xsize = X.shape[1]

X_trainingSet.columns = [str(x) for x in range(1,Xsize+1)]
X_testSet.columns = [str(x) for x in range(1,Xsize+1)]


ysize = y.shape[1]
y.columns = [str(y) for y in range(1,ysize+1)]
y_trainingSet.columns = [str(y) for y in range(1,ysize+1)]
y_testSet.columns = [str(x) for x in range(1,Xsize+1)]

X_trainingSetShort = X_trainingSet.loc[:, [str(x) for x in range(1, Xsize//2+1)]]
X_trainingSetLong = X_trainingSet.loc[:, [str(x) for x in range(Xsize//2+1, Xsize)]]
y_trainingSetShort = y_trainingSet.loc[:,[str(x) for x in range(1, Xsize//2+1)]]
y_trainingSetLong = y_trainingSet.loc[:,[str(x) for x in range(Xsize//2+1, Xsize)]]
# define and fit the final model
modelShort = Sequential()
modelShort.add(Dense(Xsize, input_dim=Xsize, activation='relu'))
modelShort.add(Dense(40, activation='relu'))
modelShort.add(Dense(20, activation='relu'))
modelShort.add(Dense(10, activation='relu'))
modelShort.add(Dense(4, activation='relu'))
modelShort.add(Dense(2, activation='relu'))
modelShort.add(Dense(ysize, activation='linear'))
modelShort.compile(loss='mse', optimizer='Adamax')
print("now fitting...")
modelShort.fit(X_trainingSet, y_trainingSet, epochs=20, verbose=1, validation_split=0.2)
# new instance where we do not know the answer
# make a prediction
ynew = modelShort.predict(X_testSet)
yplot = np.append(ynew, y_testSet.values)
# show the inputs and predicted outputs
#pd.DataFrame.plot.scatter((1,1),(1,1))
#print("X=%s, Predicted=%s" % (X_testSet[0], ynew[0]))

np.savetxt("ynew.csv", ynew, delimiter=",")
np.savetxt("X_testSet.csv", X_testSet, delimiter=",")
np.savetxt("y_testSet.csv", y_testSet, delimiter=",")
modelShort.save('autoencodershort.h5')
