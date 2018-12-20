%n,Reff,mua1,mus1,aDb1,tau,lambda,rho,w,ell,mua2,mus2,aDb2
n = 1.4;
Reff = .493;
mua1 = .2;
mus1 = 10;
aDb1 = .5e-8
%aDb1 = .1e-8:.2e-8:3e-8;%cm2/s
tau = DelayTime(1:50);
lambda = 830; %nm
%rho = [1, 2.5]; %cm
rho = 1;
w = 0;
ell = 0.5;
%ell = 0.5:.25:2; %cm
mua2 = .2;
mus2 = 10;
%aDb2 = .2e-8:.2e-8:3e-8; %cm2/s
aDb2 = .5e-8;
beta = .5;

% cutoff=1.05;
% datalength=130;
% bin_width = 1e-6;
% DelayTime=[1e-6:bin_width:bin_width*datalength];
% tau = DelayTime

%tau = DelayTime(1:130);
t=1 %integration time

[amp phase] = diffusionforwardsolver(n,Reff,mua1,mus1,aDb1,tau,lambda,rho,w,ell,mua2,mus2,aDb2);
zero = diffusionforwardsolver(n,Reff,mua1,mus1,aDb1,0,lambda,rho,w,ell,mua2,mus2,aDb2);

scatter(log(tau),amp/zero);
hold on
scatter(log(tau),
