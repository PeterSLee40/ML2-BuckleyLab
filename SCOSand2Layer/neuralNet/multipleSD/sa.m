net1 = fitnet(20,'trainscg');
net1 = train(net1, inputshuffle', targetshuffledb2');
net2 = fitnet([10 3],'trainscg');
net2 = train(net2, inputshuffle', targetshuffledb2');
net3 = fitnet(5,'trainbr');
net3 = train(net3, inputshuffle', targetshuffledb2');
