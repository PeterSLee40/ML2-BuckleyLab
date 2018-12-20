# import libraries
import numpy as np
import matplotlib
matplotlib.use('TkAgg')
import pandas as pd
import matplotlib.pyplot as plt
matplotlib.use('TkAgg')
from sklearn.neural_network import MLPRegressor
from sklearn.model_selection import cross_val_score, train_test_split, GridSearchCV
from sklearn.metrics import mean_squared_error
import csv
import sys
import keras;
# from joblib import dump


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
            fData.append((row[0:639]))
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


def modelling_HT(fData, fTarget):
    parameter_space = {
        "hidden_layer_sizes": [(1), (50, 50, 50), (100), (500)],
        "activation": ["tanh", "relu"],  # default is relu
        "solver": ["lbfgs", "sgd", "adam"],  # default is adam
        "alpha": [0.001, 0.05, 0.1]
    }
    regr = MLPRegressor(max_iter=2000, random_state=2018)
    clf = GridSearchCV(regr, parameter_space, n_jobs=-1, cv=5)

    x_train, x_test, y_train, y_test = dataSplit(fData, fTarget, 0.2)
    clf.fit(x_train, y_train)

    # best parameter
    print("best parameters: ", clf.best_params_)

    # if you want to see the every grid you set above
    for mean, std, params in zip(clf.cv_results_['mean_test_score'], clf.cv_results_['std_test_score'],
                                 clf.cv_results_['params']):
        print("%0.3f (+/-%0.03f) for %r" % (mean, std * 2, params))

    # prediction based on the best
    y_pred = clf.predict(x_test)

    evaluation(clf, regr, y_test, y_pred, x_test)
    dump(clf, 'net.joblib')
    print("complete")


def evaluation(trained, regr, y_test, y_pred, x_test):
    """

    :param trained: model that was trained from previous step
    :param y_test:
    :param y_pred:
    :return:
    """

    # mse4  = mean_squared_error(y_test[:,3],y_pred[:,3])
    # mse5  = mean_squared_error(y_test[:,4],y_pred[:,4])
    # Kappa_model_json = trained.to_json()
    # with open("model.json", "w") as json_file:
    #     json_file.write(Kappa_model_json)
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
    #print("mse2")
    #print(mse2)
    #print("mse3")
    # print(mse3)
    #
    percentErr = abs(y_pred[:, 0] - y_test[:, 0]) / y_test[:, 0]
    avgPercentErr = percentErr.mean()
    print("Db-error")
    print(percentErr)
    print(avgPercentErr)
    '''
    percentErr = abs(y_pred[:, 1] - y_test[:, 1]) / y_test[:, 1]
    avgPercentErr = percentErr.mean()
    print("a-error")
    print(percentErr)
    print(avgPercentErr)

    percentErr = abs(y_pred[:, 2] - y_test[:, 2]) / y_test[:, 2]
    avgPercentErr = percentErr.mean()
    print("b-error")
    print(percentErr)
    print(avgPercentErr)
    '''

    #plt.subplot(1, 3, 1)
    plt.plot(y_test[:, 0], y_pred[:, 0], 'ro')
    plt.plot(y_test[:, 0], y_test[:, 0], 'b--')
    # plt.ylim(0,3)
    # plt.xlim(0,3)
    plt.title('Db')
    plt.ylabel('Predicted')
    plt.xlabel('Actual')
    plt.show()
    '''
    plt.subplot(1, 3, 2)
    plt.plot(y_test[:, 1], y_pred[:, 1], 'ro')
    plt.plot(y_test[:, 1], y_test[:, 1], 'b--')
    # plt.ylim(0,20)
    # plt.xlim(0,20)
    plt.title('a')
    plt.ylabel('Predicted')
    plt.xlabel('Actual')
    # plt.show()

    plt.subplot(1, 3, 3)
    plt.plot(y_test[:, 2], y_pred[:, 2], 'ro')
    plt.plot(y_test[:, 2], y_test[:, 2], 'b--')
    # plt.ylim(.2,4)
    # plt.xlim(.2,4)
    plt.title('b')
    plt.ylabel('Predicted')
    plt.xlabel('Actual')
    plt.show()
    '''


def main(fileName, encoding="utf8", hyper=1):
    fData, fTarget = readData("nn8SDinttime10_inputtarget.csv")

    if hyper:  # use hyperparameter tuning
        modelling_HT(fData, fTarget)
    else:
        modelling_noHT(fData, fTarget)


if __name__ == "__main__":
    fileName = sys.argv[1]
    encoding = sys.argv[2]
    hyper = int(sys.argv[3])

    main(fileName, encoding, hyper)