
#Author: Peter Lee, Plee40@gatech.edu
import numpy as np
import matplotlib
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.neural_network import MLPRegressor
from sklearn.model_selection import cross_val_score, train_test_split, GridSearchCV
from sklearn.metrics import mean_squared_error
from sklearn.preprocessing import StandardScaler
import csv
import sys
import keras
from math import exp
from keras import Sequential, regularizers
from keras.layers import Dense
import itertools
from keras.callbacks import EarlyStopping,ReduceLROnPlateau, LearningRateScheduler
from keras import optimizers

# from joblib import dump
bestparams = None
bestReg = None
minerror = float('inf')
history = None
def createNeuralNet(Xsize,Ysize, opt="Adam",loss='mean_squared_error',
    HLayers = (1), actFunc = 'relu'):
    model = Sequential()
    model.add(Dense(Xsize, input_dim = Xsize,  activation=actFunc,
                            kernel_regularizer=regularizers.l2(0.00),
                            activity_regularizer=regularizers.l1(0.00)))
    if type(HLayers) == tuple:
        for curLayerSize in HLayers:
            model.add(Dense(curLayerSize, activation=actFunc,
                            kernel_regularizer=regularizers.l2(0.00),
                            activity_regularizer=regularizers.l1(0.00)))
    else:
        model.add(Dense(HLayers, activation=actFunc))
    model.add(Dense(Ysize))
    #model.add(Dense(Ysize, '''activation='linear'''',
    #                        kernel_regularizer=regularizers.l2(0.01),
    #                        activity_regularizer=regularizers.l1(0.01)))
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
        fData = np.array(fData)
        fData = fData.astype(np.float)
        fTarget = np.array(fTarget)
        fTarget = fTarget.astype(np.float)
    return fData, fTarget


def dataSplit(fData, fTarget, ratio=0.1):
    x_train, x_test, y_train, y_test = train_test_split(fData, fTarget, test_size=ratio)
    return x_train, x_test, y_train, y_test

'''
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
'''
def GridSearchKeras(Dsize, Tsize, X, Y, params, max_iter=10):
    #iterate through each hidden layer size, activation function, solver, and alpha.
    global minerror,bestParams,bestReg, history
    paramsList = list()
    paramsList.append(params['hidden_layer_sizes'])
    paramsList.append(params['activation'])
    paramsList.append(params['solver'])
    paramsList.append(params['alpha'])
    allCombos = list(itertools.product(*paramsList))
    for params in allCombos:
        print("current params:"),print(*params, sep = ", ")  
        opt= eval("optimizers." + params[2] + "(lr = " + str(params[3]) + ")")
        reg = createNeuralNet(Dsize, Tsize, opt = opt, HLayers = params[0], actFunc = params[1])
        #earlyStop = EarlyStopping(monitor='val_loss', patience = 10, mode='auto')
        reduce_lr = ReduceLROnPlateau(monitor='val_loss', factor=0.1,
                              patience=3, min_lr=0.00001)
        history = reg.fit(X, Y, batch_size=100, callbacks = [reduce_lr], epochs = max_iter, validation_split = .2)
        error = reg.evaluate(X, Y)
        plotHistory(history)
        if error < minerror:
            minerror = error
            bestParams = params
            bestReg = reg
    return bestReg, bestParams;

def modelling_HT(fData, fTarget):
    global minerror,bestParams,bestReg, history
    parameter_space = {
        "hidden_layer_sizes": [(64, 8)],
        "activation": ["relu"],  # default is relu
        "solver": ["Adam"],  # default is adam
        "alpha": [0.001]
    }
    Datasize = fData.shape[1]
    if (type(fTarget) == list):
        Targetsize = fTarget.shape[1]
    else: 
        Targetsize = 1
    #regr = MLPRegressor(max_iter=2000, random_state=2018)
    #reg = GridSearchCV(regr, parameter_space, n_jobs=-1, cv=5)
    
    x_train, x_test, y_train, y_test = train_test_split(fData, fTarget, test_size=.2)
    scaler = StandardScaler()
    scaler.fit(x_train)
    x_train = scaler.transform(x_train)
    x_test = scaler.transform(x_test)
    #this will anneal the learning rate, reducing it as the performance plateaus
    reduce_lr = ReduceLROnPlateau(monitor='val_loss', factor=0.1,
                              patience=5, min_lr=0.00001)
    earlyStop = EarlyStopping(monitor='val_loss', patience = 10, mode='auto')
    [bestReg, bestParams] = GridSearchKeras(Datasize, Targetsize, x_train, y_train, parameter_space, max_iter=200)
    history = bestReg.fit(x_train, y_train, batch_size=100, callbacks = [earlyStop, reduce_lr], epochs = 200, validation_split = .1)
    # best parameter
    plotHistory(history)
    print("best parameters: ")
    print(*bestParams, sep = ", ")  
    # if you want to see the every grid you set above
    '''
    for mean, std, params in zip(reg.cv_results_['mean_test_score'], reg.cv_results_['std_test_score'],
                                 reg.cv_results_['params']):
        print("%0.3f (+/-%0.03f) for %r" % (mean, std * 2, params))
        '''
    # prediction based on the best
    y_pred = bestReg.predict(x_test)
    loss = mean_squared_error(y_test, y_pred)
    print(loss)
    print("complete")
    return bestReg

def plotHistory (history):
    plt.plot(history.history['loss'])
    plt.plot(history.history['val_loss'])
    plt.title('model mse')
    plt.ylabel('mse')
    plt.xlabel('epoch')
    plt.legend(['train', 'val'], loc='upper left')
    plt.show()
'''
def evaluation(trained, regr, y_test, y_pred, x_test):
    
    result = trained.score(x_test, y_test)
    mse1 = mean_squared_error(y_test, y_pred[:, 0])
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
    '''

fileName = "nn8SDinttime10_inputtarget.csv"
fData, fTarget = readData(fileName)
a = modelling_HT(fData, fTarget)
#evaluate(a)
