addpath('F:\SCOSand2Layer\functions');
first_delay=2e-7;
for I=1:16,
    DelayTime(I) = I*first_delay;
end
 
for J=1:30,
    for I=0:7,
        DelayTime(I+(J-1)*8+17) = DelayTime((J-1)*8+16+I)+first_delay*(2^J);
    end
end
DelayTime=DelayTime(1:256);
T = diff([0, DelayTime]);

%n,Reff,mua1,mus1,aDb1,tau,lambda,rho,w,ell,mua2,mus2,aDb2
n = 1.4;
Reff = .493;
mua1 = .2;
mus1 = 10;
%aDb1 = .5e-8
aDb1 = .1e-8:.2e-8:3e-8;%cm2/s
lambda = 852; %nm
rho = [1, 2.5]; %cm
w = 0;
%ell = 0.5;
ell = 0.5:.25:2; %cm
mua2 = .1;
mus2 = 10;
aDb2 = .2e-8:.2e-8:3e-8; %cm2/s
%aDb2 = .5e-8
beta = .5;
tau = DelayTime(1:130);
t=1 %integration time
e=exp(1);



