# -*- coding: utf-8 -*-
"""
Created on Sat Nov 17 21:51:12 2018

@author: PeterLee
"""
import sklearn.decomposition as decomp
import numpy as np
import matplotlib.pyplot as plt
from kneed import KneeLocator
from mpl_toolkits.mplot3d import Axes3D
X_train,y_train  = np.load('X_train.npy'), np.load('y_train.npy')
X_test, y_test = np.load('X_test.npy'), np.load('y_test.npy')


import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


from sklearn import decomposition


fig = plt.figure(1, figsize=(4, 3))
plt.clf()
#ax = Axes3D(fig, rect=[0, 0, .95, 1], elev=48, azim=134)
ax = fig.add_subplot(111, projection = '3d')
plt.cla()
pca = decomposition.PCA(n_components=3)
pca.fit(X_train)

#edit to generate figure for training set vs test set

#X = pca.transform(X_train)
#y = y_train


X = pca.transform(X_test)
y = y_test[:,1]
# Reorder the labels to have colors matching the cluster results
ax.scatter(X[:, 0], X[:, 1], X[:, 2],c = y,cmap='viridis')

ax.set_xlabel([])
ax.set_ylabel([])
ax.set_zlabel([])
#edit
#plt.savefig('BreastData3dtest.png')

plt.show()