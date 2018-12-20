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
X, y = pd.read_csv("TSG_db2_2_input.csv"), pd.read_csv("TSG_db2_2_inputnn.csv")

X_trainingSet, X_testSet, y_trainingSet, y_testSet = train_test_split(X, y, test_size=.2)
Xsize = X.shape[1]
halfXsize = Xsize//2
X_trainingSet.columns = [str(x) for x in range(1,Xsize+1)]
X_testSet.columns = [str(x) for x in range(1,Xsize+1)]
y_trainingSet.columns = [str(x) for x in range(1,Xsize+1)]
y_testSet.columns = [str(x) for x in range(1,Xsize+1)]

y.columns = [str(y) for y in range(1,Xsize+1)]


X_trainingSetShort = X_trainingSet.loc[:, [str(x) for x in range(1, halfXsize+1)]]
X_trainingSetLong = X_trainingSet.loc[:, [str(x) for x in range(halfXsize+1, Xsize+1)]]
y_trainingSetShort = y_trainingSet.loc[:,[str(x) for x in range(1, halfXsize+1)]]
y_trainingSetLong = y_trainingSet.loc[:,[str(x) for x in range(halfXsize+1, Xsize+1)]]
# define and fit the final model
modelShort = Sequential()
modelShort.add(Dense(halfXsize, input_dim=halfXsize, activation='relu'))
modelShort.add(Dense(10, activation='relu'))
modelShort.add(Dense(5, activation='relu'))
modelShort.add(Dense(10, activation='relu'))
modelShort.add(Dense(halfXsize, activation='linear'))
modelShort.compile(loss='mse', optimizer='Adamax')

modelLong = Sequential()
modelLong.add(Dense(halfXsize, input_dim=halfXsize, activation='relu'))
modelLong.add(Dense(10, activation='relu'))
modelLong.add(Dense(5, activation='relu'))
modelLong.add(Dense(10, activation='relu'))
modelLong.add(Dense(halfXsize, activation='linear'))
modelLong.compile(loss='mse', optimizer='Adamax')

print("now fitting...")
modelShort.fit(X_trainingSetShort, y_trainingSetShort, epochs=20, verbose=1, validation_split=0.2)
modelShort.fit(X_trainingSetLong, y_trainingSetLong, epochs=20, verbose=1, validation_split=0.2)

# new instance where we do not know the answer
# make a prediction
# show the inputs and predicted outputs
#pd.DataFrame.plot.scatter((1,1),(1,1))
#print("X=%s, Predicted=%s" % (X_testSet[0], ynew[0]))

modelShort.save('autoencoder2short.h5')
modelLong.save('autoencoder2long.h5')

autoencoder2eval.py
runfile('C:/Users/PeterLee/Documents/GitHub/ML-Multilayer/SCOSand2Layer/Keras-NeuralNet/autoencoder2eval.py', wdir='C:/Users/PeterLee/Documents/GitHub/ML-Multilayer/SCOSand2Layer/Keras-NeuralNet')