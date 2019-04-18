# -*- coding: utf-8 -*-
"""
Created on Wed Dec 19 22:11:54 2018

@author: PeterLee
"""

#Author: Peter Lee, Plee40@gatech.edu
import numpy as np
import matplotlib
matplotlib.use('TkAgg')
import pandas as pd
import matplotlib.pyplot as plt
matplotlib.use('TkAgg')
from sklearn.neural_network import MLPRegressor
from sklearn.model_selection import cross_val_score, train_test_split, GridSearchCV
from sklearn.metrics import mean_squared_error
from sklearn.preprocessing import StandardScaler
import csv
import sys
import keras
from keras import Sequential
from keras.layers import Dense
import itertools
from keras.callbacks import EarlyStopping  
from keras import optimizers
from sklearn.metrics import mean_squared_error

# from joblib import dump

def createNeuralNet(Xsize,Ysize, opt="Adam",loss='mean_squared_error',
    HLayers = (1), actFunc = 'relu'):
    model = Sequential()
    model.add(Dense(Xsize, input_dim = Xsize,  activation=actFunc))
    if type(HLayers) == tuple:
        for curLayerSize in HLayers:
            model.add(Dense(curLayerSize, activation=actFunc))
    else:
        model.add(Dense(HLayers, activation=actFunc))
        
    model.add(Dense(Ysize))
    model.compile(loss='mean_squared_error', optimizer = opt)
    return model

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
        #     other.append(row[491:495])
        # other = np.array(other)
        # other = other.astype(np.float)
        fData = np.array(fData)
        fData = fData.astype(np.float)
        fTarget = np.array(fTarget)
        fTarget = fTarget.astype(np.float)

    return fData, fTarget


def dataSplit(fData, fTarget, ratio=0.1):
    """

    :param fData: X
    :param fTarget: Y
    :param ratio: ratio of train/test split; 0 < ratio < 1.0
    :return:
    """
    x_train, x_test, y_train, y_test = train_test_split(fData, fTarget, test_size=ratio)
    return x_train, x_test, y_train, y_test


def storeItermediate(y_test, y_pred, x_test):
    with open('mueffNoise1OutYtest.csv', 'w') as out:
        csv_out = csv.writer(out)
        csv_out.writerows(y_test)
    with open('mueffNoise1OutYpred.csv', 'w') as outTwo:
        csv_outTwo = csv.writer(outTwo)
        csv_outTwo.writerows(y_pred)
    with open('mueffNoise1OutXtest.csv', 'w') as outThree:
        csv_outTwo = csv.writer(outThree)
        csv_outTwo.writerows(x_test)
    print('file written')


def modelling_noHT(fData, fTarget):
    regr = MLPRegressor(solver='lbfgs', hidden_layer_sizes=(500), max_iter=2000, random_state=2018)
    x_train, x_test, y_train, y_test = dataSplit(fData, fTarget)

    trained = regr.fit(x_train, y_train[0])
    y_pred = trained.predict(x_test)

    evaluation(trained, regr, y_test, y_pred, x_test)
    dump(trained, 'net.joblib')
    print("complete")

def GridSearchKeras(Datasize, Targetsize, X, Y, params, max_iter=2000):
    #iterate through each hidden layer size, activation function, solver, and alpha.
    paramsList = list()
    paramsList.append(params['hidden_layer_sizes'])
    paramsList.append(params['activation'])
    paramsList.append(params['solver'])
    paramsList.append(params['alpha'])
    allCombos = list(itertools.product(*paramsList))
    
    bestReg = None
    minerror = float('inf');
    for params in allCombos:
        print("current params:"),print(*params, sep = ", ")  
        opt= eval("optimizers." + params[2] + "(lr = " + str(params[3]) + ")")
        reg = createNeuralNet(Datasize, Targetsize, opt = opt, HLayers = params[0], actFunc = params[1])
        earlyStop = EarlyStopping(monitor='val_loss', patience = 10, mode='auto')
        fitting = reg.fit(X, Y, batch_size=100, callbacks = [earlyStop], epochs = max_iter, validation_split = .1, steps_per_epoch = 5)
        error = reg.evaluate(X, Y)
        if error < minerror:
            minerror = error
            bestParams = params
            bestReg = reg
    return bestReg, bestParams;

def modelling_HT(fData, fTarget):
    parameter_space = {
        "hidden_layer_sizes": [(200, 50, 5),(160, 40, 4), (600,30), (500)],
        "activation": ["tanh", "Relu"],  # default is relu
        "solver": ["SGD", "Adam", "Adadelta", "Nadam", "RMSprop"],  # default is adam
        "alpha": [0.0001, 0.001, 0.01]
    }
    Datasize = fData.shape[1]
    if (type(fTarget) == list):
        Targetsize = fTarget.shape[1]
    else: 
        Targetsize = 1
    #regr = MLPRegressor(max_iter=2000, random_state=2018)
    #reg = GridSearchCV(regr, parameter_space, n_jobs=-1, cv=5)
    
    x_train, x_test, y_train, y_test = train_test_split(fData, fTarget, test_size=.2)
    Xsize = Datasize
    ysize = Targetsize
    scaler = StandardScaler()
    scaler.fit(x_train)
    x_train = scaler.transform(x_train)
    x_test = scaler.transform(x_test)
    
    earlyStop = EarlyStopping(monitor='val_loss', patience = 6, mode='auto')
    [reg, bestParams] = GridSearchKeras(Datasize, Targetsize, x_train, y_train, parameter_space, max_iter=2000)
    history = reg.fit(x_train, y_train, batch_size=100, callbacks = [earlyStop], epochs = 2000, validation_split = .1, steps_per_epoch = 5)
    # best parameter
    print("best parameters: ")
    for params in bestParams:
        print(*params, sep = ", ")  
    # if you want to see the every grid you set above
    '''
    for mean, std, params in zip(reg.cv_results_['mean_test_score'], reg.cv_results_['std_test_score'],
                                 reg.cv_results_['params']):
        print("%0.3f (+/-%0.03f) for %r" % (mean, std * 2, params))
        '''
    # prediction based on the best
    y_pred = reg.predict(x_test)
    loss = mean_squared_error(y_test, y_pred)
    print(loss)
    print("complete")
    return reg


def evaluation(trained, regr, y_test, y_pred, x_test):
    
    result = trained.score(x_test, y_test)
    mse1 = mean_squared_error(y_test, y_pred[:, 0])
    #mse2 = mean_squared_error(y_test, y_pred[:, 1])
    #mse3 = mean_squared_error(y_test[:, 2], y_pred[:, 2])
    print("score")
    print(result)
    print("loss")
    print(regr.loss_)
    print("mse1")
    print(mse1)
    percentErr = abs(y_pred[:, 0] - y_test[:, 0]) / y_test[:, 0]
    avgPercentErr = percentErr.mean()
    print("Db-error")
    print(percentErr)
    print(avgPercentErr)
    plt.plot(y_test[:, 0], y_pred[:, 0], 'ro')
    plt.plot(y_test[:, 0], y_test[:, 0], 'b--')
    plt.title('Db')
    plt.ylabel('Predicted')
    plt.xlabel('Actual')
    plt.show()

fileName = "nn8SDinttime10_inputtarget.csv"
fData, fTarget = readData(fileName)
a = modelling_HT(fData, fTarget)
