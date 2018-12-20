# -*- coding: utf-8 -*-
"""
Created on Tue Oct  2 18:29:14 2018

@author: PeterLee
"""
from keras.models import Sequential
from keras.models import load_model
from keras.layers import Dense
from sklearn.datasets import make_regression
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split  
import pandas as pd
from numpy import array
import numpy as np
noisy = pd.read_csv("TSG_db2_2_input.csv") 
noisysize = noisy.shape[1]
halfSize = noisysize//2
noisy.columns = [str(x) for x in range(1,noisysize+1)]

autoencodershort = load_model('autoencoder2short.h5')
autoencoderlong = load_model('autoencoder2long.h5')

noisyShort = noisy.loc[:,[str(x) for x in range(1, halfSize+1)]]
noisyLong = noisy.loc[:,[str(x) for x in range(halfSize+1, noisysize+1)]]

denoisedShort = autoencodershort.predict(noisyShort)
denoisedLong = autoencodershort.predict(noisyLong)

#eval

#concat

np.savetxt("TSG_db2_2_denoisedshort.csv", denoisedShort, delimiter=",")
np.savetxt("TSG_db2_2_denoisedlong.csv", denoisedLong, delimiter=",")



