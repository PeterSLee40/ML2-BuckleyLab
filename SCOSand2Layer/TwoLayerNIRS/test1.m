addpath('../functions')
constants
load('gauss_lag_5000.mat')
w = 1.1;
l = 1.0
db1 = aDb1(1);
db2 = aDb2(1);
l = ell(1);
rho = 1;
[amp, phase] = diffusionforwardsolverPL(n,Reff,mua1,mus1,db1,tau,lambda,rho,w,l,mua2,mus2,db2, gl);
curve = [amp, phase];
fun = @(x) diffusionforwardsolvercost(x, n,Reff,db1,tau,lambda,rho,w,db2, curve);
x0 = [.3, 5, .3, 5, 1.0]; % mua1, mus1, mua2, mus2
lb = [.01, 1, .01, 1, .2];
ub = [1, 20, 1, 20, 2.0];
%do optimization given initial guess, upper bound, and lowerbound
options = optimoptions(@lsqnonlin,'Algorithm','trust-region-reflective');
options.Algorithm = 'levenberg-marquardt';
x = LevenbergMarquardt(fun,x0,lb,ub, options);

