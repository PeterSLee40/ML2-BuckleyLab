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

#takes in the file location of a csv and splits it up into input data and target
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
            fData.append((row[0:640]))
            fTarget.append(row[641])
        fData = np.array(fData)
        fData = fData.astype(np.float)
        fTarget = np.array(fTarget)
        fTarget = fTarget.astype(np.float)
    return fData, fTarget
#creates a neural net with an input size Xsize, output size Ysize, with a given
#optimizer, loss function, hiddenlayers, and activation function.
def createNeuralNet(Xsize,Ysize, opt="Adam",loss='mean_squared_error',
    HLayers = (1), actFunc = 'relu'):
    model = Sequential()
    model.add(Dense(Xsize, input_dim = Xsize))
    model.add(Activation(actFunc))
    #model.add(BatchNormalization())
    #model.add(Dropout(0.5))

    if type(HLayers) == tuple:
        for curLayerSize in HLayers:
            model.add(Dense(curLayerSize))
            model.add(Activation(actFunc))
            #model.add(BatchNormalization())
            #model.add(Dropout(0.5))
    else:
        model.add(Dense(HLayers))
        model.add(Activation(actFunc))
        #model.add(BatchNormalization())
        #model.add(Dropout(0.5))
    model.add(Dense(Ysize))
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

fileName = "../../multipleSD/nn8SDinttime10_inputtarget.csv"
fData, fTarget = readData(fileName)
x_train = np.load("x_train_nn8SDinttime10_training1.npy")
x_test = np.load("x_test_nn8SDinttime10_training1.npy")
y_train = np.load("y_train_nn8SDinttime10_training1.npy")
y_test = np.load("y_test_nn8SDinttime10_training1.npy")
#x_train, x_test, y_train, y_test = train_test_split(fData, fTarget, test_size=.2)
#scale the data
scaler = StandardScaler()
scaler.fit(x_train)
x_train = scaler.transform(x_train)
x_test = scaler.transform(x_test)
goodscaler = scaler

#create the hyper-parameters
learningrate = 0.01
opt= optimizers.Adam(lr = learningrate)
HiddenLayers = (10)
Datasize = fData.shape[1]
if (type(fTarget) == list):
    Targetsize = fTarget.shape[1]
else: 
    Targetsize = 1
reg = createNeuralNet(Datasize, Targetsize, opt = opt, HLayers = HiddenLayers, actFunc = 'relu')
earlyStop = EarlyStopping(monitor='val_loss', patience = 10, mode='auto')
reduce_lr = ReduceLROnPlateau(monitor='val_loss', factor=0.1,
                      patience=3, min_lr=0.00001)
#begin training
history = reg.fit(x_train, y_train, batch_size=100, callbacks = [reduce_lr, earlyStop], epochs = 1000, validation_split = .2)
error = reg.evaluate(x_test, y_test)
#plot the learning curves.
plotHistory(history)
reg.save('nn8SDinttime10_Keras_tuning_training1.h5')
