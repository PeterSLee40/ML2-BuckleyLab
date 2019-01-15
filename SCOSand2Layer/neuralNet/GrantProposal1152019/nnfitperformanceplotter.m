
db2estimate = net1(testset')';
testError = 100*(testTarget-db2estimate)./testTarget;
nnfitperformanceplotterfunc(testthiccness, testTarget, testError)