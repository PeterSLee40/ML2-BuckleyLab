function DenoisingAutoencoder(data, Y)
[N, n] = size(data);
X = data
Y
X4D = reshape(X, [1 n 1 N])

layers = [imageInputLayer([1 n]) fullyConnectedLayer(n) regressionLayer()];

opts = trainingOptions('sgdm');

net = trainNetwork(X4D, Y', layers, opts);
R = predict(net, X4D)';