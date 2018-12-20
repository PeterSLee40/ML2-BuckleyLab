# -*- coding: utf-8 -*-
"""
Created on Thu Oct 11 13:08:30 2018

@author: PeterLee
"""

# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import Dropout
from keras.layers.normalization import BatchNormalization
from sklearn.datasets import make_regression
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split  
import pandas as pd
from numpy import array
import numpy as np
from keras.optimizers import Adam
import keras.layers as layers
from keras import regularizers
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt

print("importing has completed...")
# generate regression dataset
X, y = pd.read_csv("TSG_db2_4_input.csv"), pd.read_csv("TSG_db2_4_target.csv")

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=.2)
Xsize = X.shape[1]

X_train.columns = [str(x) for x in range(1,Xsize+1)]
X_test.columns = [str(x) for x in range(1,Xsize+1)]


ysize = y.shape[1]
y.columns = [str(y) for y in range(1,ysize+1)]
y_train.columns = [str(y) for y in range(1,ysize+1)]
y_test.columns = [str(y) for y in range(1,ysize+1)]

scaler = StandardScaler()
scaler.fit(X_train)
X_train = scaler.transform(X_train)
X_test = scaler.transform(X_test)


# define and fit the final model
model = 0
model = "lol"
model = Sequential()
model.add(Dense(Xsize, input_dim=Xsize, activation='relu',kernel_regularizer=regularizers.l2(0.01),
                activity_regularizer=regularizers.l1(0.01)))
model.add(Dense(50, input_dim=Xsize, activation='relu',kernel_regularizer=regularizers.l2(0.01),
                activity_regularizer=regularizers.l1(0.01)))
model.add(Dense(10, input_dim=Xsize, activation='relu',kernel_regularizer=regularizers.l2(0.01),
                activity_regularizer=regularizers.l1(0.01)))
model.add(Dense(1, activation='linear'))
model.compile(loss='mse', optimizer='Adadelta')
print("now fitting...")
model.fit(X_train, y_train, epochs=20, verbose=1, validation_split=0.4)

model1 = Sequential()
model1.add(Dense(Xsize, input_dim=Xsize, activation='relu'))
model1.add(Dense(50, input_dim=Xsize, activation='relu'))
model1.add(Dense(10, input_dim=Xsize, activation='relu'))
model1.add(Dense(1, activation='linear'))
model1.compile(loss='mse', optimizer='Adadelta')
print("now fitting...")
model1.fit(X_train, y_train, epochs=5, verbose=1, validation_split=0.4)
# new instance where we do not know the answer
# make a prediction
ynew = model.predict(X_test)
a = (ynew-y_test)/y_test*100
ynew = model1.predict(X_test)

a1 = (ynew-y_test)/y_test*100

yplot = np.append(ynew, y_test.values)
# show the inputs and predicted outputs
#pd.DataFrame.plot.scatter((1,1),(1,1))
#print("X=%s, Predicted=%s" % (X_test[0], ynew[0]))

np.savetxt("ynew.csv", ynew, delimiter=",")
np.savetxt("X_test.csv", X_test, delimiter=",")
np.savetxt("y_test.csv", y_test, delimiter=",")
model.save('db2solver4.h5')
