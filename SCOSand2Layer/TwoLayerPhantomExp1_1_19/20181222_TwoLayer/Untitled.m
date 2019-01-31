
options = trainingOptions('sgdm', ...
    'InitialLearnRate',1e-8, ...
    'Verbose',false, ...
    'MaxEpochs',200, ...
    'MiniBatchSize',64, ...
    'Plots','training-progress');

layers = [ ...
    sequenceInputLayer(213)
    fullyConnectedLayer(100)
    fullyConnectedLayer(10)
    fullyConnectedLayer(1)
    regressionLayer
    ];
net = trainNetwork(inputshuffle', targetshuffledb2',layers,options);
j = 0
for a = 1:size(testSet,1)
    data = testSet(a, :)';
    j = j + 1;
    trial_db2Prediction(j) = predict(net, data);
end
mean(trial_db2Prediction)