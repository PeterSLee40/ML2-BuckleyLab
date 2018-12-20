x = inputshuffle';
t = targetshuffle'*10;
net1 = fitnet(50,'trainscg');
net1 = train(net1,x,t);
y = net1(x);
perf = perform(net1,y,t)

net2 = fitnet(50, 'trainscg');
x2 = [x' y']';
net2 = train(net2,x2,t);
y2 = net2(x2);
perf = perform(net2,y2,t)

net3 = fitnet(50, 'trainscg');
x3 = [x2' y']';
net3 = train(net3,x3,t);
y2 = net3(x3);
perf = perform(net3,y2,t)