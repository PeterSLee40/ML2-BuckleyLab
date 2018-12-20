
addpath('F:\functions');
index = 1e3;

g2_25 = inputshuffle2(index,1:51);
g2_15 = inputshuffle2(index,51:100);

output = NoNoiseNet1(inputshuffle2(index,:)');
fitdb1 = output(1)*1e-8;
fitdb2 = output(2)*1e-8;
l = output(3);
constants
tau = DelayTime(1:1:50);
T = diff(DelayTime(1:1:51));

fitg1_15 = diffusionforwardsolver(n,Reff,mua1,mus1,fitdb1,tau,lambda,rho(2),w,l,mua2,mus2,fitdb2);
fitg2_15 = beta + fitg1_15./fitg1_15(1)
figure, semilogx(g2_15);
hold on
semilogx(fitg2_15);
targetshuffle(index,:);