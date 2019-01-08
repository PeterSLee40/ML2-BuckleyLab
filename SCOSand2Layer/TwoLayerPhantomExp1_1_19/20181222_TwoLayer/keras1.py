# -*- coding: utf-8 -*-
"""
Created on Fri Dec 21 01:50:38 2018

@author: PeterLee
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.neural_network import MLPRegressor
from sklearn.model_selection import cross_val_score, train_test_split, GridSearchCV
from sklearn.metrics import mean_squared_error
from sklearn.preprocessing import StandardScaler
import csv
import keras
from math import exp
from keras import Sequential, regularizers
from keras.layers import Dense, BatchNormalization, Activation, Dropout
from keras.callbacks import EarlyStopping,ReduceLROnPlateau, LearningRateScheduler
from keras import optimizers
from keras.models import load_model

# Creates a HDF5 file 'my_model.h5'
def readData(fileName, encoding="utf8"):
    """
    :param fileName: input file name
    :param encoding: encoding type
    :return: X and Y data
    """
    fData = []
    fTarget = []

    with open(fileName, "r", encoding=encoding) as f:
        reader = csv.reader(f)
        for row in reader:
            fData.append((row[0:213]))
            fTarget.append(row[214])
        fData = np.array(fData)
        fData = fData.astype(np.float)
        fTarget = np.array(fTarget)
        fTarget = fTarget.astype(np.float)
    return fData, fTarget
def createNeuralNet(Xsize,Ysize, opt="Adam",loss='mean_squared_error',
    HLayers = (1), actFunc = 'relu'):
    model = Sequential()
    model.add(Dense(Xsize, input_dim = Xsize,kernel_initializer='he_uniform',
                kernel_regularizer=regularizers.l2(0.0),
                activity_regularizer=regularizers.l1(0.0)))
    model.add(Activation(actFunc))
    #model.add(BatchNormalization())
    #model.add(Dropout(0.5))

    if type(HLayers) == tuple:
        for curLayerSize in HLayers:
            model.add(Dense(curLayerSize,kernel_initializer='he_uniform',
                kernel_regularizer=regularizers.l2(0.00),
                activity_regularizer=regularizers.l1(0.00)))
            model.add(Activation(actFunc))
            #model.add(BatchNormalization())
    #        model.add(Dropout(0.5))
    else:
        model.add(Dense(HLayers))
        model.add(Activation(actFunc))
        #model.add(BatchNormalization())
     #   model.add(Dropout(0.5))
    model.add(Dense(Ysize,kernel_initializer='he_uniform'))
    model.compile(loss='mean_squared_error', optimizer = opt)
    return model
def plotHistory (history):
    plt.plot(history.history['loss'])
    plt.plot(history.history['val_loss'])
    plt.title('model mse')
    plt.ylabel('mse')
    plt.xlabel('epoch')
    plt.legend(['train', 'val'], loc='upper left')
    plt.show()

fileName = "inputtarget.csv"
fData, fTarget = readData(fileName)
x_train, x_test, y_train, y_test = train_test_split(fData, fTarget, test_size=.15)

#x_train = np.load("x_train_nn8SDinttime3_training1.npy")
#x_test = np.load("x_test_nn8SDinttime3_training1.npy")
#y_train = np.load("y_train_nn8SDinttime3_training1.npy")
#y_test = np.load("y_test_nn8SDinttime3_training1.npy")

scaler = StandardScaler()
scaler.fit(x_train)
x_train = scaler.transform(x_train)
x_test = scaler.transform(x_test)
#goodscaler = scaler

learningrate = 0.01
opt= optimizers.Adam(lr = learningrate)
HiddenLayers = (4, 2)
Datasize = fData.shape[1]
if (type(fTarget) == list):
    Targetsize = fTarget.shape[1]
else: 
    Targetsize = 1
reg = createNeuralNet(Datasize, Targetsize, opt = opt, HLayers = HiddenLayers, actFunc = 'relu')
earlyStop = EarlyStopping(monitor='val_loss', patience = 20, mode='auto')
reduce_lr = ReduceLROnPlateau(monitor='val_loss', factor=0.3,
                      patience=3, min_lr=0.00001)

history = reg.fit(x_train, y_train, batch_size=16, callbacks = [reduce_lr, earlyStop], epochs = 1000, validation_split = .15)
error = reg.evaluate(x_test, y_test)
plotHistory(history)
reg.save('nn8SDinttime3_Keras_tuning_training1.h5')
