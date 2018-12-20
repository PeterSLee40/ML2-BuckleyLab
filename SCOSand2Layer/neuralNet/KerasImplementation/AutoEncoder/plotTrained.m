ynew = csvread('ynew.csv');
X_testSet = csvread('X_testSet.csv');
y_testSet = csvread('y_testSet.csv');
index = 20
semilogx(ynew(index,:));
hold on; semilogx(X_testSet(index,:));
hold on; semilogx(y_testSet(index,:));
legend("denoised","noisy","no-noise")