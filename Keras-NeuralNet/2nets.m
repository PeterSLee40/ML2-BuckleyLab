x = inputshuffle';
t = targetshuffle';
net1 = fitnet(10,'trainscg');

net1 = train(net1,x,t);
y = net1(x);
perf = perform(net1,y,t)


x = [x' y']'
net2 = train(fitnet(10, 'trainscg'),x,t);
perf = perform(net1,y,t)

view(net2)
y = net2(x);
